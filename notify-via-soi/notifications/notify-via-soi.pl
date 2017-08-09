#!/usr/bin/env perl
# Forward Notifications to CA-SOI
# Bulk: no

########################################################################
# INCLUDES #############################################################
use v5.10;
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Net::FTP;
use Carp;
use File::Temp qw(tempfile);
use Time::HiRes;
use POSIX qw(strftime);
use Monitoring::Livestatus;
########################################################################
# END INCLUDES #########################################################

# parameters
GetOptions(
	'help|h|?' => sub {pod2usage(-verbose => 99, -sections => 'NAME|SYNOPSIS|DESCRIPTION|OPTIONS|ARGUMENTS|VERSION')},
	'noFTPUpload'    => \(our $noFTPUpload = 0),
	'showTestGuide'  => sub{pod2usage(-verbose => 99, -sections => 'SEE ALSO')},
) or pod2usage(1);
pod2usage(1) if $ARGV[0];

# Just in case of problems, let's not hang check_mk
$SIG{'ALRM'} = sub {
	say "Timed out";
	exit(2);
};

# Get all NOTIFY_ Variables from Environment and store it in Hash %p
our %p = map {$_ =~ /^NOTIFY_(.*)/ ? ($1 => $ENV{$_}) : ()} keys %ENV;

# Set defaults:
$p{PARAMETER_TIMEOUT} = $p{PARAMETER_TIMEOUT} || 3;

my $time = Time::HiRes::gettimeofday;
our $TIMESTAMP = strftime('%Y-%m-%dT%H:%M:%S+02:00', localtime($time));
our $FILENAME  = strftime('T%Y%m%d_%H%M%S_', localtime($time)) . sprintf("%03i.xml", (($time * 1000) % 1000));

sub _substitute_context {
	my ($string) = @_;
	warn "D-_substiture_context: substitute the following string: '" . $string . "'" if $p{PARAMETER_DEBUG};
	foreach my $key (keys %p) {
		my $val = $p{$key};
		$string =~ s/\$$key\$/$val/m;
	}
	warn "D-_substiture_context: to: '" . $string . "'" if $p{PARAMETER_DEBUG};
	return $string;

}

sub _get_xml {

# EXAMPLE XML
#<?xml version='1.0' encoding='UTF-8'?>
#<usm:silodatalist xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:usm='http://www.ca.com/usm' xsi:type='usm:SiloDataList'>
#	<silodata entitytype='Alert'>
#		<properties>
#			<property  name='entitytype'           value='Alert' />
#			<property  name='action'               value='Create' />
#			<property  name='eventtype'            value='Alert' />
#			<property  name='id'                   value='123' />
#			<property  name='AlertType'            value='Risk' />
#			<property  name='Severity'             value='Critical' />
#			<property  name='Summary'              value='testAlarm' />
#			<property  name='Message'              value='super duper interface . down' />
#			<property  name='DeviceName'           value='switchXY' />
#			<property  name='DeviceType'           value='Switch' />
#			<property  name='ResourceName'         value='interface 123' />
#			<property  name='ResourceType'         value='undefined' />
#			<property  name='OccurrenceTimestamp'  value='T2016-05-19 15:00:15+02:00' />
#			<property  name='ReportTimestamp'      value='T2016-05-19 15:00:15+02:00' />
#			<property  name='AlertedMdrElementID'  value='switchXY' />
#		</properties>
#	</silodata>
#</usm:silodatalist>

	my ($ALARMID, $SEVERITY, $HEADLINE, $HOSTNAME, $HOSTTYPE, $RESOURCENAME, $RESOURCETYPE, $ALERTTEXT) = @_;
	my $xml_template = "<?xml version='1.0' encoding='UTF-8'?>
<usm:silodatalist xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:usm='http://www.ca.com/usm' xsi:type='usm:SiloDataList'>
	<silodata entitytype='Alert'>
		<properties>
			<property  name='entitytype'           value='Alert' />
			<property  name='action'               value='Create' />
			<property  name='eventtype'            value='Alert' />
			<property  name='id'                   value='" . $ALARMID . "' />
			<property  name='AlertType'            value='RISK' />
			<property  name='Severity'             value='" . $SEVERITY . "' />
			<property  name='Summary'              value='" . $HEADLINE . "' />
			<property  name='Message'              value='" . $ALERTTEXT . "' />
			<property  name='DeviceName'           value='" . $HOSTNAME . "' />
			<property  name='DeviceType'           value='" . $HOSTTYPE . "' />
			<property  name='ResourceName'         value='" . $RESOURCENAME . "' />
			<property  name='ResourceType'         value='" . $RESOURCETYPE . "' />
			<property  name='OccurrenceTimestamp'  value='" . $TIMESTAMP . "' />
			<property  name='ReportTimestamp'      value='" . $TIMESTAMP . "' />
			<property  name='AlertedMdrElementID'  value='" . $HOSTNAME . "' />
		</properties>
	</silodata>
</usm:silodatalist>";

	warn "D-_get_xml: Constructed the following xml:\n" . $xml_template if $p{PARAMETER_DEBUG};

	my ($fh, $filename) = tempfile($FILENAME . '_XXXX', SUFFIX => '.xml', TMPDIR => 1, UNLINK => ($p{PARAMETER_KEEPXML} ? 0 : 1));
	print $fh $xml_template;
	seek $fh, 0, 0;
	return ($fh, $filename);
}    # ----------  end of subroutine get_xml ----------

sub livestatus {
	my ($query) = @_;
	warn "D-livestatus: doing the following query: " . $query if $p{PARAMETER_DEBUG};
	
	my @livesockets;
	my @user = getpwuid($<);
	if (-d $user[7] && -S $user[7] . '/tmp/run/live') {
		 push(@livesockets, $user[7] . '/tmp/run/live');
	} 
	if (-d $user[7] && -d $user[7] . '/tmp/run/liveproxy') {
		my @tmpsockets = glob $user[7] . '/tmp/run/liveproxy/*';
		@tmpsockets = grep { -S $_ } @tmpsockets;
		push(@livesockets, @tmpsockets);
	}
	croak "can't automatically set livesocket, specify it via WATO GUI PARAMETER <TODO>\n" if @livesockets == 0;
	


	my $live =
	  Monitoring::Livestatus->new(peer => \@livesockets, query_timeout => $p{PARAMETER_TIMEOUT} - 1, verbose => 0, use_threads => 0);
	$live->errors_are_fatal(0);
	my $vars = $live->selectall_arrayref($query);
	if ($Monitoring::Livestatus::ErrorCode) {
		croak 'D-livestatus: ' . $Monitoring::Livestatus::ErrorMessage;
	}
	warn "D-livestatus: ...and got this answer:" . Dumper($vars) if $p{PARAMETER_DEBUG};

	# asume that it is only possible to have one Alerttext comment, so we can use index 0 of the returned arrayref;
	if (wantarray) {
		return ($vars->[0][0], $vars->[0][1]);
	} else {
		return $vars->[0][0];
	}

}    # ----------  end of subroutine livestatus  ----------

sub _get_ALARMID {

	# Generate unique ID for SOI and safe it as Host/Service-comment in check_mk (ALARMID-$TIMESTAMP-HOSTNAME[-SERVICEDESC])
	# or get it from check_mk if this is not a new alarm.

	my $epoch = strftime('%s', localtime($time));
	my ($ret, $id, $existingComment, $existingID);
	
	# Auslesen
	if ($p{WHAT} eq 'SERVICE'){
		($existingComment, $existingID) =
			  livestatus(  "GET comments\nColumns: comment_comment comment_id\nFilter: host_name = "
						 . $p{HOSTNAME}
						 . "\nFilter: service_description = "
						 . $p{SERVICEDESC}
						 . "\nFilter: comment_comment ~ ^ALARMID\n");
	} else {
		($existingComment, $existingID) =
			  livestatus(  "GET comments\nColumns: comment_comment comment_id\nFilter: host_name = "
						 . $p{HOSTNAME}
						 . "\nFilter: service_description = \nFilter: comment_comment ~ ^ALARMID\n");
	}
	

	if ($p{WHAT} eq 'SERVICE' && $p{NOTIFICATIONTYPE} eq 'PROBLEM' && $p{PREVIOUSSERVICEHARDSTATEID} < 1) {

		# erste Service Notification Critical/Warning/UNKNOWN
		# ->Eintragen
		warn "D-_get_ALARMID: first Service Notification -> generate and store ID via livestatus" if $p{PARAMETER_DEBUG};
		if( $existingID ){
			# Aus ungeklährten umständen existiert bereits eine ID für den Service
			# ->lösche alte ID, und trage neue ein. Achtung, falls der alte Alarm in SOI noch besteht wird er nicht automatisch durch ein Service Recovery gelöscht.
			livestatus("COMMAND [" . $epoch . "] DEL_SVC_COMMENT;" . $existingID . "\n");
		}
		livestatus(  "COMMAND ["
				   . $epoch
				   . "] ADD_SVC_COMMENT;"
				   . $p{HOSTNAME} . ";"
				   . $p{SERVICEDESC}
				   . ";1;SOI-CONNECTOR;"
				   . "ALARMID-"
				   . $TIMESTAMP . "-"
				   . $p{HOSTNAME} . "-"
				   . $p{SERVICEDESC}
				   . "\n");
		$ret = "ALARMID-" . $TIMESTAMP . "-" . $p{HOSTNAME} . "-" . $p{SERVICEDESC};

	} elsif ($p{WHAT} eq 'SERVICE' && $p{NOTIFICATIONTYPE} eq 'PROBLEM' && $p{PREVIOUSSERVICEHARDSTATEID} >= 1) {

		# weitere Service Notification Critical/Warning/UNKNOWN
		# ->Auslesen
		warn "D-_get_ALARMID: not first Service Notification but still PROBLEM -> just read ID from livestatus"
		  if $p{PARAMETER_DEBUG};
		  
		$ret = $existingComment;
		if (!$ret ) {
			# Aus ungeklährten umständen bisher kein Servicekommentar vorhanden.  
			# ->Eintragen
			livestatus(  "COMMAND ["
				   . $epoch
				   . "] ADD_SVC_COMMENT;"
				   . $p{HOSTNAME} . ";"
				   . $p{SERVICEDESC}
				   . ";1;SOI-CONNECTOR;"
				   . "ALARMID-"
				   . $TIMESTAMP . "-"
				   . $p{HOSTNAME} . "-"
				   . $p{SERVICEDESC}
				   . "\n");
			$ret = "ALARMID-" . $TIMESTAMP . "-" . $p{HOSTNAME} . "-" . $p{SERVICEDESC};
		}
	} elsif ($p{WHAT} eq 'SERVICE' && ($p{NOTIFICATIONTYPE} eq 'RECOVERY' || $p{NOTIFICATIONTYPE} eq 'ACKNOWLEDGEMENT')) {

		# Service Notification geht wieder auf OK oder Acknowledgement des Service durch user
		# ->Auslesen & löschen
		warn "D-_get_ALARMID: Service Recovery -> read ID from livestatus and delete it" if $p{PARAMETER_DEBUG};
		$ret = $existingComment;
		if (!$ret ) {
			croak 'No Comment found, either it was acknowledged before or we have a race condition. This is ok';
		}
		livestatus("COMMAND [" . $epoch . "] DEL_SVC_COMMENT;" . $existingID . "\n");

	} elsif ($p{WHAT} eq 'HOST' && $p{NOTIFICATIONTYPE} eq 'PROBLEM' && $p{PREVIOUSHOSTHARDSTATEID} < 1) {

		# erste Host Notification Down/Unreach
		# ->Eintragen
		warn "D-_get_ALARMID: first Host Notification -> generate and store ID via livestatus" if $p{PARAMETER_DEBUG};
		if( $existingID ){
			# Aus ungeklährten umständen existiert bereits eine ID für den Service
			# ->lösche alte ID, und trage neue ein. Achtung, falls der alte Alarm in SOI noch besteht wird er nicht automatisch durch ein Service Recovery gelöscht.
			livestatus("COMMAND [" . $epoch . "] DEL_HOST_COMMENT;" . $existingID . "\n");
		}	
		livestatus(  "COMMAND ["
				   . $epoch
				   . "] ADD_HOST_COMMENT;"
				   . $p{HOSTNAME}
				   . ";1;SOI-CONNECTOR;"
				   . "ALARMID-"
				   . $TIMESTAMP . "-"
				   . $p{HOSTNAME}
				   . "\n");
		$ret = "ALARMID-" . $TIMESTAMP . "-" . $p{HOSTNAME};

	} elsif ($p{WHAT} eq 'HOST' && $p{NOTIFICATIONTYPE} eq 'PROBLEM' && $p{PREVIOUSHOSTHARDSTATEID} >= 1) {

		# weitere HOST Notification Down/Unreach
		# ->Auslesen
		warn "D-_get_ALARMID: not first Host Notification but still PROBLEM -> just read ID from livestatus"
		  if $p{PARAMETER_DEBUG};
		$ret = $existingComment;
		if (!$ret ) {
			# Aus ungeklährten umständen bisher kein Hostkommentar vorhanden.  
			# ->Eintragen
			livestatus(  "COMMAND ["
				   . $epoch
				   . "] ADD_HOST_COMMENT;"
				   . $p{HOSTNAME}
				   . ";1;SOI-CONNECTOR;"
				   . "ALARMID-"
				   . $TIMESTAMP . "-"
				   . $p{HOSTNAME}
				   . "\n");
		$ret = "ALARMID-" . $TIMESTAMP . "-" . $p{HOSTNAME};
		}
		
	} elsif ($p{WHAT} eq 'HOST' && ($p{NOTIFICATIONTYPE} eq 'RECOVERY' || $p{NOTIFICATIONTYPE} eq 'ACKNOWLEDGEMENT')) {

		# HOST Notification geht wieder auf OK oder Acknowledgement des Hosts durch user
		# ->Auslesen & löschen
		warn "D-_get_ALARMID: Host Recovery -> read ID from livestatus and delete it" if $p{PARAMETER_DEBUG};
		$ret = $existingComment;
		if (!$ret ) {
			croak 'No Comment found, either it was acknowledged before or we have a race condition. This is ok';
		}
		livestatus("COMMAND [" . $epoch . "] DEL_HOST_COMMENT;" . $existingID . "\n");

	} else {

		# Sollte nicht vorkommen oder
		#CUSTOM NOTIFICATION -> könnte noch als Kommentarfunktion für Ticket genutzt werden, bisher nicht implementiert.
		croak 'Notification Type not supported: ' . $p{WHAT} . '->' . $p{NOTIFICATIONTYPE};
	}

	# ALARMID max length = 255
	return substr($ret, 0, 255);

}    # ----------  end of subroutine get_ALARMID  ----------

sub main {
	warn "D-main! Script is running in this Environment Context:" . Dumper(\%p) if $p{PARAMETER_DEBUG};

	# All Variables neede to generate the XML and its defaults:
	my ($ALARMID, $SEVERITY, $HEADLINE, $HOSTNAME, $HOSTTYPE, $RESOURCENAME, $RESOURCETYPE, $ALERTTEXT) =
	  ('', 'Critical', '', '', 'Server', '', 'undefined', '');

	warn "D-main: setting Timout for the notification handler - " . $p{PARAMETER_TIMEOUT} . "s" if $p{PARAMETER_DEBUG};
	alarm($p{PARAMETER_TIMEOUT});

	# ALARMID - AlarmID is stored in check_mk as Host/Service comment

		warn "D-main: calling _get_ALARMID()" if $p{PARAMETER_DEBUG};
		$ALARMID = _get_ALARMID(); 
		
			
		warn "D-main: got ALARMID: '" . $ALARMID . "'" if $p{PARAMETER_DEBUG};

	# DEVICENAME/HOSTNAME
	$HOSTNAME = $p{HOSTNAME};
	warn "D-main: setting HOSTNAME: '" . $HOSTNAME . "'" if $p{PARAMETER_DEBUG};

# DEVICETYPE/HOSTTYPE
# TODO - Information in check_mk nicht vorhanden. Daher wird über bekannte Muster versucht den Typ zu ermitteln, als default wird Server gesetzt.
	if ($HOSTNAME =~ /^V91|V92/) {
		$HOSTTYPE = 'Switch';
	} else {
		$HOSTTYPE = 'Server';
	}
	warn "D-main: setting HOSTTYPE: '" . $HOSTTYPE . "'" if $p{PARAMETER_DEBUG};

	# What kind of Notification is it?
	if ($p{NOTIFICATIONTYPE} eq "PROBLEM") {
		if ($p{WHAT} eq 'HOST') {
			$SEVERITY = 'Critical';
		} else {
			$SEVERITY = ($p{SERVICESTATEID} > 1 ? 'Critical' : 'Minor');
		}
	} elsif ($p{NOTIFICATIONTYPE} eq "RECOVERY" || $p{NOTIFICATIONTYPE} eq "ACKNOWLEDGEMENT") {
		$SEVERITY = 'Normal';
	} elsif ($p{NOTIFICATIONTYPE} eq "CUSTOM") {
		say "CUSTOM Notifications are not yet implemented";
		exit 2;
	} elsif ($p{NOTIFICATIONTYPE} =~ /^FLAP/) {
		say "Notifications for Flapping is not implemented";
		exit 2;
	} else {
		say "UNKNOWN NOTIFICATIONTYPE";
		exit 2;
	}
	warn "D-main: setting SEVERITY: '" . $SEVERITY . "'" if $p{PARAMETER_DEBUG};

	# HEADLINE
	$HEADLINE = _substitute_context($p{WHAT} eq "HOST" ? $p{PARAMETER_HOSTHEADLINE} : $p{PARAMETER_SERVICEHEADLINE});
	warn "D-main: setting HEADLINE: '" . $HEADLINE . "'" if $p{PARAMETER_DEBUG};

	# RESOURCENAME
	$RESOURCENAME = $p{WHAT} eq "HOST" ? $HOSTNAME : $p{SERVICEDESC};
	warn "D-main: setting RESOURCENAME: '" . $RESOURCENAME . "'" if $p{PARAMETER_DEBUG};

	# RESOURCETYPE
	# TODO - Information in check_mk nicht vorhanden. Daher wird über bekannte Muster versucht den Typ zu ermitteln.
	# Weitere einfügen...
	if ($p{WHAT} eq "HOST") {
		$RESOURCETYPE = "Response.ICMP";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check-mk$/ && $p{SERVICEOUTPUT} =~ /^(Agent|CRIT - Check_MK|Cannot get data from TCP)/)
	{
		$RESOURCETYPE = "Response.Agent";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check-mk$/ && $p{SERVICEOUTPUT} =~ /^SNMP/) {
		$RESOURCETYPE = "Response.SNMP";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check-mk-ping$/) {
		$RESOURCETYPE = "Response.ICMP";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check_mk-(if|.*_if|.*bonding)/) {
		$RESOURCETYPE = "Interface.*";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check_mk-(df|mounts)/) {
		$RESOURCETYPE = "File.Filesystem";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check_mk-(.*disk)/) {
		$RESOURCETYPE = "Disk.*";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check_mk-(kernel\.util|.*cpu)/) {
		$RESOURCETYPE = "Cpu.*";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check_mk-(.*mem)/) {
		$RESOURCETYPE = "Memory.*";
	} elsif ($p{SERVICECHECKCOMMAND} =~ /^check_mk-(systemtime|ntp.time)/) {
		$RESOURCETYPE = "System.*";
	} else {
		$RESOURCETYPE = "System.Misc";
	}
	warn "D-main: setting RESOURCETYPE: '" . $RESOURCETYPE . "'" if $p{PARAMETER_DEBUG};

	# ALERTTEXT
	$ALERTTEXT = ($p{WHAT} eq "HOST" ? $p{PARAMETER_HOSTBODY} : $p{PARAMETER_SERVICEBODY});
	$ALERTTEXT .= "\nsee: " . $p{PARAMETER_URL_PREFIX} . ($p{WHAT} eq "HOST" ? $p{HOSTURL} : $p{SERVICEURL});
	$ALERTTEXT = _substitute_context($ALERTTEXT);
	warn "D-main: setting ALERTTEXT: '" . $ALERTTEXT . "'" if $p{PARAMETER_DEBUG};

	warn "D-main: calling _get_xml()" if $p{PARAMETER_DEBUG};

	# XML Parameter fertig:
	my ($xml_fh, $tmp_file) =
	  _get_xml($ALARMID, $SEVERITY, $HEADLINE, $HOSTNAME, $HOSTTYPE, $RESOURCENAME, $RESOURCETYPE, $ALERTTEXT);
	warn "D-main: Tempxml: " . $tmp_file . "'" if $p{PARAMETER_DEBUG};

	if ( $noFTPUpload ){
		warn "D-main: skipping ftp upload, you requested to not upload the xml." if $p{PARAMETER_DEBUG};
	} else {
		warn "D-main: starting ftp upload to: 'ftp://" . $p{PARAMETER_SOISERVER} . $p{PARAMETER_FTPPATH} . "'" if $p{PARAMETER_DEBUG};
		my $ftp;
		$ftp = Net::FTP->new($p{PARAMETER_SOISERVER})
		  || croak "unable to create ftp connection to '$p{PARAMETER_SOISERVER}'" . $ftp->message;
		$ftp->login($p{PARAMETER_FTPUSER}, $p{PARAMETER_FTPPASSWORD})
		  || croak "unable to connect as '$p{PARAMETER_FTPUSER}'" . $ftp->message;
		$ftp->cwd($p{PARAMETER_FTPPATH}) || croak "unable to change to path '$p{PARAMETER_FTPPATH}'" . $ftp->message;
		$ftp->put($xml_fh, $FILENAME) || croak "unable to transfer file '$FILENAME'" . $ftp->message;
		$ftp->quit;
		warn "D-main: ftp upload successful. exiting" if $p{PARAMETER_DEBUG};

	}
}
main();
exit(0);

########################################################################
# POD ##################################################################

=head1 NAME

notify-via-soi.pl - Forward Notifications to CA-SOI

=head1 SYNOPSIS
    This is a notificationscript for check_mk monitoring software
    it puts an XML File via FTP into CA-SOIs spool directory.
    The script supports the generation and acknowledgement of alerts.

    The Rulebased Notification Rule should honor the following settings to work properly:

    - You must not use Bulking
    - Make sure you dont generate multiple Notifications for a single Alert.
      e.g. add a single useraccount and select only this user in 'Contact Selection'
      tab.
    - 'Match host event type' and 'Match service event type':
      - must not contain 'start or stop flapping' notification
      - must not contain 'start or stop scheduled downtime' notification
      - must contain 'Acknowledgement of service/host problem'
      - state changes as you prefer.

    configure your notification settings accordingly if you don't use RBN.

    All parameters necessary to make this notification handler work
    are given via Environment Variables prefixed with 
    /^NOTIFY_.*/ (Notification Context Parameters from cmc) and 
    /^NOTIFY_PARAMETER_.*/ (User supplied Parameters via WATO). A WATO File
    for configuration is present so you don't have to care about the parameters below.

    PARAMETER_TIMEOUT <Timeout> in s; default: 3s
    PARAMETER_DEBUG prints additional debug messages on STDERR which gets redirected to ~/var/log/notify.log
    PARAMETER_KEEPXML do not delete the genereated xml file, its path and name is printed to notify.log if debug is enabled.

    PARAMETER_HOSTHEADLINE Shorttext used in xml summary field if a Hostnotification is raised.
    PARAMETER_SERVICEHEADLINE Shorttext used in xml summary field if a Servicenotification is raised.

    PARAMETER_HOSTBODY Longtext used in xml Message field if a Hostnotification is raised.
    PARAMETER_SERVICEBODY Longtext used in xml Message field if a Servicenotificationis raised.

    PARAMETER_URL_PREFIX to link to the main site if you use distributed Monitoring.
    
    PARAMETER_SOISERVER IP Address of the SOI Server receiving the XML via FTP
    PARAMETER_FTPUSER Username used to connect to the SOI Server via FTP
    PARAMETER_FTPPASSWORD Password used to connect to the SOI Server via FTP
    PARAMETER_FTPPATH Path where we put the XML on the FTP Server
    

    This parameter may be usfull to test the script from cli:

    --help,-h,-?    prints this helpmessage
    --noFTPUpload   skips the final step, uploading the xml to the FTP
    --showTestGuide prints detailed instructios on how to test the skript.
    
=head1 SEE ALSO

  Um das Skript zu testen sind folgende Schritte nötig
  Voraussetzungen:
  - das Skript muss mit dem/einen site Benutzer ausgeführt werden.
  - die environment Variablen müssen gesetzt werden z.B. so für ein Beispiel Critical Meldung 

  $ cat <<'EOF' >/tmp/notify-via-soi.cirt.env
  export NOTIFY_HOSTNAME='<HOSTNAME EINES AUF DER SITE ÜBERWACHTEN HOSTS>'
  # z.B. export NOTIFY_HOSTNAME='X9350657'
  export NOTIFY_SERVICEDESC='<BELIEBIGER SERVICE DES HOSTS>'
  # z.B. export NOTIFY_SERVICEDESC='fs_/tmp'
  export NOTIFY_SERVICECHECKCOMMAND='check_mk-df'
  export NOTIFY_SERVICEOUTPUT='test'
  export NOTIFY_PREVIOUSSERVICEHARDSTATEID='0'
  export NOTIFY_NOTIFICATIONTYPE='PROBLEM'
  export NOTIFY_SERVICEURL='/check_mk/index.py?start_url=view.py%3Fview_name%3Dservice%26host%3DX9350657%26service%3Dfs_/tmp'
  export NOTIFY_PARAMETER_URL_PREFIX='http://10.233.22.135/rzn_zentral'
  export NOTIFY_PARAMETER_FTPPASSWORD='prod#1234'
  export NOTIFY_PARAMETER_TIMEOUT='3'
  export NOTIFY_PARAMETER_SOISERVER='10.233.22.27'
  export NOTIFY_PARAMETER_SERVICEHEADLINE='$HOSTNAME$ ($HOSTALIAS$ - $HOSTADDRESS$) - $SERVICEDESC$'
  export NOTIFY_PARAMETER_FTPPATH='/in'
  export NOTIFY_PARAMETER_DEBUG='yes'
  export NOTIFY_PARAMETER_HOSTHEADLINE='$HOSTNAME$ ($HOSTALIAS$ - $HOSTADDRESS$) - $HOSTSTATE$'
  export NOTIFY_PARAMETER_FTPUSER='FTP-Nagios'
  export NOTIFY_PARAMETER_HOSTBODY='$HOSTOUTPUT$ bla blub'
  export NOTIFY_PARAMETER_SERVICEBODY='Service:  $SERVICEDESC$'
  export NOTIFY_WHAT='SERVICE'
  EOF

  $ source /tmp/notify-via-soi.cirt.env

  - oder so für eine Beispiel OK Meldung

  $ cat <<'EOF' >/tmp/notify-via-soi.ok.env
  export NOTIFY_HOSTNAME='<HOSTNAME EINES AUF DER SITE ÜBERWACHTEN HOSTS>'
  # z.B. export NOTIFY_HOSTNAME='X9350657'
  export NOTIFY_SERVICEDESC='<BELIEBIGER SERVICE DES HOSTS>'
  # z.B. export NOTIFY_SERVICEDESC='fs_/tmp'
  export NOTIFY_SERVICECHECKCOMMAND='check_mk-df'
  export NOTIFY_SERVICEOUTPUT='test'
  export NOTIFY_PREVIOUSSERVICEHARDSTATEID='2'
  export NOTIFY_NOTIFICATIONTYPE='RECOVERY'
  export NOTIFY_SERVICEURL='/check_mk/index.py?start_url=view.py%3Fview_name%3Dservice%26host%3DX9350657%26service%3Dfs_/tmp'
  export NOTIFY_PARAMETER_URL_PREFIX='http://10.233.22.135/rzn_zentral'
  export NOTIFY_PARAMETER_FTPPASSWORD='prod#1234'
  export NOTIFY_PARAMETER_TIMEOUT='3'
  export NOTIFY_PARAMETER_SOISERVER='10.233.22.27'
  export NOTIFY_PARAMETER_SERVICEHEADLINE='$HOSTNAME$ ($HOSTALIAS$ - $HOSTADDRESS$) - $SERVICEDESC$'
  export NOTIFY_PARAMETER_FTPPATH='/in'
  export NOTIFY_PARAMETER_DEBUG='yes'
  export NOTIFY_PARAMETER_HOSTHEADLINE='$HOSTNAME$ ($HOSTALIAS$ - $HOSTADDRESS$) - $HOSTSTATE$'
  export NOTIFY_PARAMETER_FTPUSER='FTP-Nagios'
  export NOTIFY_PARAMETER_HOSTBODY='$HOSTOUTPUT$ bla blub'
  export NOTIFY_PARAMETER_SERVICEBODY='Service:  $SERVICEDESC$'
  export NOTIFY_WHAT='SERVICE'
  EOF

  $ source /tmp/notify-via-soi.ok.env

  - Danach kann das skript gestartet werden:
  $ ~/local/share/check_mk/notifications/notify-via-soi.pl --help
  $ ~/local/share/check_mk/notifications/notify-via-soi.pl --noFTPUpload
  
  - nach dem Ausführen mit dem crit Environment muss auf dem entspr. Service in der check_mk GUI ein Kommentar erscheinen
  - nach dem Ausführen mit dem OK Environment müssen alle Kommentare des Service in der check_mk GUI wieder verschwunden sein.

=head1 VERSION

1.3

=head1 AUTHOR

Markus Weber - markus.weber@lfst.bayern.de

=head1 LICENSE

GPLv2

=cut
