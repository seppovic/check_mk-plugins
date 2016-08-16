#!/usr/bin/env perl
# isms
# Bulk: no

########################################################################
# INCLUDES #############################################################
use v5.10;
use strict;
use warnings;
use Getopt::Long 'HelpMessage';
use Data::Dumper;
use IO::Socket::INET;
########################################################################
# END INCLUDES #########################################################

# parameters
GetOptions('help' => sub {HelpMessage(1)}) or HelpMessage(1);
HelpMessage(1) if $ARGV[0];

# Just in case of problems, let's not hang check_mk
local $SIG{'ALRM'} = sub {
	say "Timed out";
	exit(2);
};

my %smsErrorCodes = (

#Error Code, Error Description
					 601, 'Authentication Failed',
					 602, 'Parse Error',
					 603, 'Invalid Category',
					 604, 'SMS message size is greater than 160 chars',
					 605, 'Recipient Overflow',
					 606, 'Invalid Recipient',
					 607, 'No Recipient',
					 608, 'SMSFinder is busy, can’t accept this request',
					 609, 'Timeout waiting for a TCP API request',
					 610, 'Unknown Action Trigger',
					 611, 'Error in broadcast Trigger',
					 612, 'System Error. Memory Allocation Failure',
);

sub justASCII {
	join(
		"",
		map {    # german umlauts
			$_ eq '182'                ? 'oe' :    # ö
			  $_ eq '164'              ? 'ae' :    # ä
			  $_ eq '188'              ? 'ue' :    # ü
			  $_ eq '150'              ? 'Oe' :    # Ö
			  $_ eq '132'              ? 'Ae' :    # Ä
			  $_ eq '156'              ? 'Ue' :    # Ü
			  $_ eq '159'              ? 'ss' :    # ß
			  $_ > 128                 ? '' :      # cut out anything not 7-bit ASCII
			  chr($_) =~ /[[:cntrl:]]/ ? '' :      # and control characters too
			  chr($_)                              # just the ASCII as themselves
		} unpack("U*", $_[0])
	);                                             # unpack Unicode characters
}

sub urlencode {
	my $str = "@_";
	$str =~ s/([^A-Za-z0-9%])/sprintf("%%%02X", ord($1))/seg;
	return $str;
}

sub httpGet {
	my ($hostaddress, $document, $debug) = @_;
	my $remote = IO::Socket::INET->new(Proto => "tcp", PeerAddr => $hostaddress, PeerPort => "http(80)")
	  or die "Can't bind : $@\n";
	if ($remote) {
		$remote->autoflush(1);
		print $remote "GET $document HTTP/1.1\015\012\015\012";
		my $http_answer;
		while (<$remote>) {
			$http_answer .= $_;
		}
		close $remote;
		$http_answer =~ tr/\n\r/ /;
		if ($debug) {print 'isms response  : ' . $http_answer . "\n";}
		return $http_answer;
	} else {
		return undef;
	}
}

sub substitute_context {

# %0A = zeilenumbruch
	my ($string, $pRef, $debug) = @_;
	warn "D-substiture_context: substitute the following string: '" . $string . "'" if $debug;

	foreach my $key (keys %{$pRef}) {
		my $val = $pRef->{$key};
		$string =~ s/\$$key\$/$val/gm;
	}
	$string =~ s/\n|\\n/%0A/g;

	warn "D-substiture_context: to: '" . $string . "'" if $debug;
	return $string;
}

#~ html message...
sub construct_message {
	my ($pRef, $splitmax, $debug) = @_;
	my @messages;
	my $RequestedMessage = "";
	if ($pRef->{WHAT} eq "SERVICE") {
		$RequestedMessage .= substitute_context($pRef->{PARAMETER_SERVICE_MESSAGE}, $pRef, $debug);
	} else {
		$RequestedMessage .= substitute_context($pRef->{PARAMETER_HOST_MESSAGE}, $pRef, $debug);
	}

# Split message into 160 character pieces up to $splitmax msgs
	my $offset = 0;
	$splitmax = 100 if ($splitmax == 0);
	while ($splitmax-- > 0 and length($RequestedMessage) > $offset) {
		push(@messages, urlencode(substr(justASCII($RequestedMessage), $offset, 160)));
		$offset += 160;
	}
	return @messages;
}

sub main {

# Get all NOTIFY_ Variables from Environment and store it in Hash %p
	my %p = map {$_ =~ /^NOTIFY_(.*)/ ? ($1 => $ENV{$_}) : ()} keys %ENV;

# Set defaults:
	my $debug = $p{PARAMETER_DEBUG} || undef;
	warn "D-main: xmpp notification handler start, got the following env_vars:\n" . Dumper(\%p) if $debug;

	my $timeout = $p{PARAMETER_TIMEOUT} || 10;

# Set alarm to kill the script.
	warn "D-main: setting Timout for the notification handler - " . $timeout . "s" if $debug;
	alarm($timeout);

# Further defaults:
	my $splitmax = $p{PARAMETER_SPLITMAX} || 1;
	unless ($p{CONTACTPAGER}) {
		warn "no Attribute PAGER for CONTACT found";
		exit(2);
	}
	unless ($p{PARAMETER_ISMSSERVER}) {
		warn "no Parameter \"isms Server\" given.";
		exit(2);
	}
	unless ($p{PARAMETER_USER}) {
		warn "no Parameter \"isms User\" given.";
		exit(2);
	}
	unless ($p{PARAMETER_PASSWORD}) {
		warn "no Parameter \"isms Password\" given.";
		exit(2);
	}

# Construct Message and substitute the Variables from WATO
	my @messages = construct_message(\%p, $splitmax, $debug);

	warn "D-main: constructed the following message(s) to be sent:\n" . join("\n\n", @messages) if $debug;

# send Message via isms API
	my $i = 0;
	for my $message (@messages) {

		my $document =
		    '/sendmsg?user='
		  . $p{PARAMETER_USER}
		  . '&passwd='
		  . $p{PARAMETER_PASSWORD}
		  . '&cat=1&to='
		  . $p{CONTACTPAGER}
		  . '&text='
		  . $message;
		warn "D-main: sending Message " . $i++ . " via API:\n" . $document if $debug;
		my $response = httpGet($p{PARAMETER_ISMSSERVER}, $document, $debug);

		if (defined $response) {
			if ($response =~ /ID: (\d+)/) {
				my $apimsgid   = $1;
				my $statuscode = -1;
				$document =
				  '/querymsg?user=' . $p{PARAMETER_USER} . '&passwd=' . $p{PARAMETER_PASSWORD} . '&apimsgid=' . $apimsgid;

				warn "D-main: checking send status via API:\n" . $document if $debug;
				while (1) {    # will be ended on timeout or success
					$response = httpGet($p{PARAMETER_ISMSSERVER}, $document, $debug);
					if (defined $response) {
						if ($response =~ /(Status|Err): (.+)/) {
							$statuscode = $2;
							if ($statuscode == 0) {

# 0='Done'
								warn 'D-main: send successfully. MessageID: ' . $apimsgid if $debug;
								last;
							} elsif ($statuscode == 2 or $statuscode == 3) {

# 2='In progress'  3='Request Received'
								sleep 1;
								next;
							} elsif ($statuscode == 5) {

# 5='Message ID Not Found'
								warn 'D-main: failed. With an very strange error: Message ID Not Found' if $debug;
								exit(2);    # set global critical
								last;
							} elsif ($statuscode == 1 or $statuscode == 4) {

# 1='Done with error - message is not sent to all the recipients'
# 4='Error occurred while sending the SMS from the SMSFinder'
								warn 'D-main: failed. Error: ' . $statuscode if $debug;
								exit(2);    # set global critical
								last;
							} elsif ($1 eq 'Err') {
								warn 'D-main: '
								  . join('',
										 ' failed. Error: ',
										 (defined $smsErrorCodes{$statuscode}) ? $smsErrorCodes{$statuscode} : 'unknown')
								  if $debug;
								exit(2);    # set global critical
								last;
							} else {
								warn 'D-main: failed. With an unknown response: ' . $response if $debug;
								exit(2);    # set global critical
								last;
							}
						}
					} else {
						warn 'D-main: unknown. Timeout or isms unreachable while querying result.' if $debug;
						exit(2);
						last;
					}
				}
			} elsif ($response =~ /Err: (\d+)/) {
				warn 'D-main: ' . join(' ', ' failed. Error:', (defined $smsErrorCodes{$1}) ? $smsErrorCodes{$1} : 'unknown')
				  if $debug;
				exit(2);
			} else {
				warn 'D-main: failed. With an unknown response: ' . $response if $debug;
				exit(2);
			}
		} else {
			warn 'D-main: failed. Timeout or isms unreachable while try to send message.';
			exit(2);
		}
	}
	exit(0);
}

main();
exit(0);

########################################################################
# POD ##################################################################

=head1 NAME

isms.pl - Notificationscript to send Notifications via Multitech isms server api.

=head1 SYNOPSIS
    This is a notificationscript for check_mk monitoring software
    it sends notifications via sms

    All parameters necessary to make this notification handler work
    are given via Environment Variables prefixed with
    /^NOTIFY_.*/ (Notification Context Parameters from cmc),
    /^NOTIFY_CONTACT_.*/ (Contact Context, e.g. CustomAttribut) and
    /^NOTIFY_PARAMETER_.*/ (User supplied Parameters via WATO). A WATO File
    for configuration is present so you don't have to care about the parameters below.

	PARAMETER_ISMSSERVER       IP Address or Name of the isms Server
	PARAMETER_USER             Username used to connect to the isms Server
    PARAMETER_PASSWORD         Password used to connect to the isms Server
    PARAMETER_HOST_MESSAGE     Longtext used in Message if a Hostnotification is raised.
    PARAMETER_SERVICE_MESSAGE  Longtext used in Message if a Servicenotificationis raised.
    PARAMETER_SPLITMAX         Max. Messages to send for one Notification if Text is longer than 160 characters.
    PARAMETER_TIMEOUT          <Timeout> in s; default: 10s
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
