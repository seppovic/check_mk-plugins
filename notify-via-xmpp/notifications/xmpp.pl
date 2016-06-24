#!/usr/bin/env perl
# XMPP/Jabber
# Bulk: no

########################################################################
# INCLUDES #############################################################
use v5.10;
use strict;
use warnings;
use Getopt::Long 'HelpMessage';
use Data::Dumper;
use Net::XMPP;
use Carp;
########################################################################
# END INCLUDES #########################################################

# parameters
GetOptions('help' => sub {HelpMessage(1)}) or HelpMessage(1);
HelpMessage(1) if $ARGV[0];

# Just in case of problems, let's not hang check_mk
$SIG{'ALRM'} = sub {
	say "Timed out";
	exit(2);
};

sub substitute_context {
	my ($string, $pRef, $debug) = @_;
	warn "D-substiture_context: substitute the following string: '" . $string . "'" if $debug;
	foreach my $key (keys %{$pRef}) {
		my $val = $pRef->{$key};
		$string =~ s/\$$key\$/$val/m;
	}
	warn "D-substiture_context: to: '" . $string . "'" if $debug;
	return $string;
}


sub construct_message{
	my ($pRef, $max_len, $url_prefix, $debug) = @_;
	my $message = '';
	if ($pRef->{WHAT} eq "SERVICE"){
		$message = substitute_context($pRef->{PARAMETER_SERVICE_MESSAGE}, $pRef, $debug);
	}else{
		$message = substitute_context($pRef->{PARAMETER_HOST_MESSAGE}, $pRef, $debug);
	}
	if ($max_len){
		return substr($message, 0, $max_len);
	}else{
		return $message;
	}
}


#
# xmpp_check_result: check the return value from some xmpp function execution
# input: text, result, [connection]
#
sub xmpp_check_result {
    my ($txt, $res, $cnx, $debug)=@_;
    
    if (!defined $res){
    	warn "D-xmpp_check_result: Error '$txt': result undefined. exiting...";
    	exit(2);
    }
    # res may be 0
	if ($res == 0) {
		warn "D-xmpp_check_result: $txt" if $debug;
		# result can be true or 'ok'
	} elsif ((@$res == 1 && $$res[0]) || $$res[0] eq 'ok') {
		warn "D-xmpp_check_result: $txt: " .  $$res[0] if $debug;
		# otherwise, there is some error
	} else {
		my $errmsg = $cnx->GetErrorCode() || '?';
		warn "D-xmpp_check_result: Error '$txt': " . join (': ', @$res) . "[$errmsg]";
		xmpp_logout($cnx, $debug);
		exit(2);
	}
}

#
# xmpp_logout: log out from the xmpp server
# input: connection
#
sub xmpp_logout{ 

    # HACK
    # messages may not be received if we log out too quickly...
    sleep 1;

    my ($cnx, $debug) = @_;
    $cnx->Disconnect();
    warn "Disconnect." if $debug;
}

#
# xmpp_login: login to the xmpp (jabber) server
# input: hostname, username, password, resource, security, debug
# output: an XMPP connection object
#
sub xmpp_login{
    my ($host, $user, $pw, $resource, $security, $debug) = @_;
    my $cnx = new Net::XMPP::Client(debuglevel=>$debug);
    unless ($cnx){
    	warn "D-xmpp_login: could not create XMPP client object: $!. exiting..." if $debug;
    	exit(2);
    }
    my $arghash = {
		hostname		=> $host,
		ssl_verify		=> 0x00,
		connectiontype	=> 'tcpip',
		componentname	=> $resource,
		srv				=> 1, # enable SRV lookups
	};
	
	if ($security eq "TLS"){
		$arghash->{tls} = 1;
		$arghash->{port} = 5222;
	}elsif($security eq "SSL"){
		$arghash->{ssl} = 1;
		$arghash->{port} = 5223;
	}else{
		$arghash->{port} = 5222;
	}

    my @res;
    warn "D-xmpp_login: loging in with this arguments:\n". Dumper($arghash) if $debug;
	@res = $cnx->Connect(%$arghash);
	unless (@res ){
		warn "D-xmpp_login: Could not connect to server '$host': ".($cnx->GetErrorCode()||$@);
		xmpp_logout($cnx, $debug);
		exit(2);
	}
    xmpp_check_result("Connect", \@res, $cnx, $debug);

    @res = $cnx->AuthSend(
			  'username' => $user,
			  'password' => $pw,
			  'resource' => $resource);
    xmpp_check_result('AuthSend', \@res, $cnx, $debug);
    
    return $cnx;
}

#
# xmpp_send_message: send a message to some xmpp user
# input: connection, recipient, msg, debug
#
sub xmpp_send_message{
    my ($cnx, $rcpt, $msg, $debug) = @_;

    $cnx->MessageSend('to'      => $rcpt,
		'type'		=> 'message',
		'body'		=> $msg);

    xmpp_check_result('MessageSend', 0, $cnx, $debug);
}

#
# xmpp_send_chatroom_message: send a message to a chatroom
# input: connection, recipient, jid, message, debug 
#
sub xmpp_send_chatroom_message{
    my ($cnx, $rcpt, $jid, $msg, $debug) =  @_;

    # set the presence
    my $pres = new Net::XMPP::Presence;
    my $res = $pres->SetTo("$rcpt/$jid");

    $cnx->Send($pres);

    # create/send the message
    my $groupmsg = new Net::XMPP::Message;
    $groupmsg->SetMessage(to      => $rcpt,
			  body    => $msg,
			  type    => 'groupchat');

    $res = $cnx->Send($groupmsg);
    xmpp_check_result ('Send', $res, $cnx, $debug);

    # leave the group
    $pres->SetPresence (Type=>'unavailable', To=>$rcpt);
}


sub main {
	# Get all NOTIFY_ Variables from Environment and store it in Hash %p
	my %p = map {$_ =~ /^NOTIFY_(.*)/ ? ($1 => $ENV{$_}) : ()} keys %ENV;

	
	# Set defaults:
	my $debug = $p{PARAMETER_DEBUG} || undef;
	warn "D-main: xmpp notification handler start, got the following env_vars:\n". Dumper(\%p) if $debug;
	
	my $timeout = $p{PARAMETER_TIMEOUT} || 3;
	
	# Set alarm to kill the script.
	warn "D-main: setting Timout for the notification handler - " . $timeout . "s" if $debug;
	alarm($timeout);
	
	# Further defaults:
	my $url_prefix = $p{PARAMETER_URL_PREFIX} || undef;
	my $resource = $p{PARAMETER_RESOURCE} || $ENV{OMD_SITE};
	my $max_len = $p{PARAMETER_MAX_LEN} || undef;
	my $rcpt_is_room = $p{PARAMETER_CHATROOM} || undef;
	
	my $rcpt;
	if ($p{CONTACT_XMPP}){
		$rcpt = $p{CONTACT_XMPP}; 
	}else{
		warn "no Custom Attribute XMPP for CONTACT found"; 
		exit(2);
	}
	
	my $security = $p{PARAMETER_SECURITY} || "";
	
	
	# Construct Message and substitute the Variables from WATO
	my $message = construct_message(\%p, $max_len, $url_prefix, $debug);
    warn "D-main: constructed the following message to be sent:\n " . $message if $debug;
	
	# login to xmpp
    my $cnx = xmpp_login( $p{PARAMETER_XMPPSERVER}, $p{PARAMETER_USER}, $p{PARAMETER_PASSWORD}, $resource, $security, $debug ); 
    
    # send message to recipient or chatroom
    if ($rcpt_is_room){
    	xmpp_send_chatroom_message ($cnx, $rcpt, $p{PARAMETER_USER}, $message, $debug);
    }else{
    	xmpp_send_message ($cnx, $rcpt, $message, $debug);
    }
    
    # logout and exit
    xmpp_logout($cnx, $debug);
	exit(0);
}
main();
exit(0);


########################################################################
# POD ##################################################################

=head1 NAME

xmpp.pl - sends notifications via xmpp

=head1 SYNOPSIS
    This is a notificationscript for check_mk monitoring software
    it sends notifications via xmpp

    All parameters necessary to make this notification handler work
    are given via Environment Variables prefixed with 
    /^NOTIFY_.*/ (Notification Context Parameters from cmc), 
    /^NOTIFY_CONTACT_.*/ (Contact Context, e.g. CustomAttribut) and 
    /^NOTIFY_PARAMETER_.*/ (User supplied Parameters via WATO). A WATO File
    for configuration is present so you don't have to care about the parameters below.
    
    CONTACT_XMPP               The Custom Attribute XMPP is used as recipients jid.
    
    PARAMETER_XMPPSERVER       IP Address or Name of the XMPP Server
    PARAMETER_USER             Username used to connect to the SOI Server via FTP
    PARAMETER_PASSWORD         Password used to connect to the SOI Server via FTP
    PARAMETER_RESOURCE         You can specify a resource which is used. This might be useful if 
                               you use or don't use not notification forwarding.
    PARAMETER_MAX_LEN          You can specify a maximum Length of the Message. All further characters 
                               will be truncated. Might be usefull if you have an sms gateway behind 
                               your XMPP Server.
    PARAMETER_SECURITY         Encrypt the client connection and choose which mechanism should be used. 
                               Port is automatically adjusted to 5222 or 5223
    PARAMETER_HOST_MESSAGE     Longtext used in Message if a Hostnotification is raised.
    PARAMETER_SERVICE_MESSAGE  Longtext used in Message if a Servicenotificationis raised.
    PARAMETER_URL_PREFIX       to link to the main site if you use distributed Monitoring.
    PARAMETER_CHATROOM         If activated, notifications are posted in a chatroom. Make sure that you 
                               don't generate multiple Notifications per Alarm.                      
    PARAMETER_TIMEOUT          <Timeout> in s; default: 3s
    PARAMETER_DEBUG            prints additional debug messages on STDERR which gets redirected to
                               ~/var/log/notify.log
    
    This parameter may be usfull to test the script from cli:

    --help,-h,-?    prints this helpmessage
    

=head1 VERSION

1.0

=head1 AUTHOR

Markus Weber - markus.weber@lfst.bayern.de

=head1 LICENSE

GPLv2

=cut
