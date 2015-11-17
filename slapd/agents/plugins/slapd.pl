#!/usr/bin/env perl

########################################################################
########################################################################
use v5.10;
use strict;
use warnings;
use Getopt::Long 'HelpMessage';
use Try::Tiny;
use Data::Dumper;
use Net::LDAP;
use Carp;
########################################################################
########################################################################
# parameters and plugin configuration
GetOptions(
		   'debug'       => \our $debug,
		   'Timeout|T=i' => \(my $Timeout = 3),
		   'help|?'      => sub {HelpMessage(0)},
) or HelpMessage(1);
HelpMessage(1) if $ARGV[0];

# Just in case of problems, let's not hang check_mk_agent
$SIG{'ALRM'} = sub {
	say "Plugin Timed out";
	exit(2);
};
alarm($Timeout);

our %global_vars = (
	'statistics_bytes' => {
		'search' => "cn=Bytes,cn=Statistics,cn=Monitor",
		'filter' => '(objectclass=*)',
		'attrs'  => ['monitorCounter', 'cn'],
		'scope'  => "base",
		'title'  => "Number of bytes sent",
		'info'   => "The graph shows the number of bytes sent",

	},

# Entries
	'statistics_entries' => {
							  'search' => "cn=Entries,cn=Statistics,cn=Monitor",
							  'filter' => '(objectclass=*)',
							  'attrs'  => ['monitorCounter', 'cn'],
							  'scope'  => "base",
							  'title'  => "Number of LDAP Entries",
							  'info'   => "The graph shows the number of entries sent",
	},

# Referrals
	'statistics_referrals' => {
								'search' => "cn=Referrals,cn=Statistics,cn=Monitor",
								'filter' => '(objectclass=*)',
								'attrs'  => ['monitorCounter', 'cn'],
								'scope'  => 'base',
								'title'  => "Number of LDAP Referrals",
								'info'   => "The graph shows the number of referrals sent",
	},

# read Current and Total Connections
	'connections' => {
					   'search' => 'cn=Connections,cn=Monitor',
					   'filter' => '(&(objectclass=*)(|(cn=Current)(cn=Total)))',
					   'attrs'  => ['monitorCounter', 'cn'],
					   'scope'  => "one",
					   'title'  => 'Number of Connections',
					   'info'   => 'Number of connections to the LDAP server',
	},

# waiters
	'waiters' => {
				   'search' => 'cn=Waiters,cn=Monitor',
				   'filter' => '(&(objectclass=*)(|(cn=Write)(cn=Read)))',
				   'attrs'  => ['monitorCounter', 'cn'],
				   'scope'  => 'one',
				   'title'  => "Number of Waiters",
				   'info'   => "The graph shows the number of Waiters",
	},

# operations
	'operations' => {
					  'search' => "cn=Operations,cn=Monitor",
					  'filter' => '(objectclass=*)',
					  'attrs'  => ['monitorOpInitiated', 'monitorOpCompleted', 'cn'],
					  'scope'  => 'one',
					  'title'  => "Operations",
					  'info'   => "Number of completed LDAP operations",
	}
);

########################################################################
########################################################################
# functions

# See http://www.openldap.org/faq/index.cgi?_highlightWords=csn&file=1145
sub parse_csn {
	my ($csn) = @_;
	warn "D! parse_csn: got " . $csn if $debug;
	my ($utime, $mtime, $count, $sid, $mod) = ($csn =~ m/(\d{14})\.?(\d{6})?Z#(\w{6})#(\w{2,3})#(\w{6})/g);
	warn "D! parse_csn: parsed to: utime: $utime, count: $count, sid: $sid, mod: $mod" if $debug;
	return ($utime, $count, $sid, $mod);
}    # EEND pars_csn

sub get_masteruri {
	my $conn = $_[0];
	my $result;
	my $message;
	$message = $conn->search(
							 base   => 'cn=Monitor',
							 scope  => 'sub',
							 filter => '(&(namingContexts=*)(MonitorUpdateRef=*))',
							 attrs  => ['monitorupdateref', 'namingContexts']
	);
	$message->code && croak "Failed - " . $message->error;
	croak "Failed - master uri not found." if !$message->entry(0);
	warn "D! found master uri: "
	  . $message->entry(0)->get_value('monitorupdateref') . "; "
	  . $message->code . ', '
	  . $message->error
	  if $debug;
	return $message->entry(0)->get_value('monitorupdateref');

}    # END get_masteruri

sub get_suffix {

# Return the first namingContext of the RootDSE
	my ($conn) = @_;
	my $result;
	my $message;
	my $entry;
	$message = $conn->search(
							 base   => '',
							 scope  => 'base',
							 filter => '(objectClass=*)',
							 attrs  => ['namingcontexts']
	);
	$message->code && croak "Failed - " . $message->error;
	croak "Failed - couldn't get suffix." if !$message->entry(0);
	warn "D! Found Suffix: " . $message->entry(0)->get_value('namingcontexts') . "; " . $message->code . ', ' . $message->error
	  if $debug;
	return $message->entry(0)->get_value('namingcontexts');

}    # END get_suffix

sub get_contextcsn {
	my ($conn, $base, $serverid) = @_;
	my $result;
	my $message;
	my $entry;
	my $contextcsn;
	$message = $conn->search(
							 base   => $base,
							 scope  => 'base',
							 filter => '(objectclass=*)',
							 attrs  => ['contextCSN']
	);
	$message->code && croak "Could not query for ContextCSN: " . $message->error;
	$entry = $message->entry(0);

# Get values
	foreach ($entry->get_value('contextCSN')) {
		warn "D! Found ContextCSN: " . $_ if $debug;

# Keep only ContextCSN with ServerID
		my @csn = &parse_csn($_);

# TODO Multimaster
#        if ( !$ldap_singlemaster ) {
#            if ( $serverid eq $csn[2] ) {
#                $contextcsn = $_;
#                &verbose( '2',
#                    "ContextCSN match with SID $serverid: " . $contextcsn );
#                last;
#            }
#        } else {
		$contextcsn = $_;
		warn "D! ContextCSN match with SID $serverid: " . $contextcsn if $debug;

#        }
	}
	croak "Found no ContextCSN with SID $serverid" if !$contextcsn;
	return $contextcsn;
}    # END get_contextcsn

sub get_ldap_connection {
	my ($server, $binddn, $bindpw, $secure, $version) = @_;

	my $ldap = Net::LDAP->new($server, version => $version) or die "could not connect to LDAP Server: $@";
	warn "D! successfully connected to LDAP Server: $server" if $debug;

	if ($secure eq '+tls') {
		my $message = $ldap->start_tls();
		$message->code && croak "could not start tls: " . $message->error;
		warn "D! successfully used start_tls: " . $message->code . ', ' . $message->error if $debug;
	}

# Bind witch credentials if specified or anonymously if either password or binddn is missing
	if ($binddn && $bindpw) {
		my $req_bind = $ldap->bind($binddn, password => $bindpw);
		$req_bind->code && croak "could not bind as $binddn : " . $req_bind->error;
		warn "D! successfully bound to ldap server as $binddn : " . $req_bind->code . ", " . $req_bind->error if $debug;
	} else {

		my $req_bind = $ldap->bind();
		$req_bind->code && croak "could not bind anonymously : " . $req_bind->error;
		warn "D! successfully bound to ldap server: " . $req_bind->code . ", " . $req_bind->error if $debug;
	}
	return ($ldap);
}    # END get_ldap_connection

sub get_value {
	my $conn  = $_[0];
	my $query = $_[1];
	my ($entry, $cn, $value, @tmpresult, %result);

	my $message = $conn->search(
								base   => $query->{search},
								scope  => $query->{scope},
								filter => $query->{filter},
								attrs  => $query->{attrs}
	);
	$message->code && croak "Failed - " . $message->error;
	warn "D! successfully searched in $query->{search}: " . $message->code . ', ' . $message->error if $debug;

	while ($entry = $message->shift_entry()) {
		warn "D! found an entry with this attributes: " . join(', ', $entry->attributes) if $debug;
		undef $cn;
		undef(@tmpresult);
		undef $value;

#for my $fetched_attr ($entry->attributes) {
		for my $fetched_attr (@{ $query->{attrs} }) {
			if ($fetched_attr eq 'cn' and defined($value = $entry->get_value($fetched_attr))) {
				$cn = $value;
			} elsif (defined($value = $entry->get_value($fetched_attr))) {
				push(@tmpresult, $value);
			} else {
				croak "Failed - No value found for $fetched_attr found.";
			}
		}
		@{ $result{$cn} } = @tmpresult;
	}
	return \%result;
}    # END get_value

sub get_stats {
	my ($ldap_conn, $slapd_instance) = @_;
	my $output;

# get_values for all keys in global_vars and print them line by line or print errormessage
	for my $what (keys %global_vars) {
		say "<<<slapd_stats_" . $what . ":sep(44)>>>";
		try {
			my $fetched = get_value($ldap_conn, $global_vars{$what});
			for my $key (keys %{$fetched}) {
				say $slapd_instance->{instancename} . "," . $key . "," . join(',', @{ $fetched->{$key} });
			}
		}
		catch {
			say $slapd_instance->{instancename} . "," . $_;
		};
	}
}    # END get_stats

sub get_Config {
	my ($conffile) = @_;

# Read conffile:
	unless (my $return = do $conffile) {
		croak "couldn't parse $conffile: $@" if $@;
		croak "couldn't do $conffile: $!" unless defined $return;
		croak "couldn't run $conffile" unless $return;
	}
	our @slapd_instances;
	return @slapd_instances;
}

########################################################################
########################################################################
# main

my $conffile = ($ENV{'MK_CONFDIR'} // '/etc/check_mk') . '/slapd.conf';
warn 'D! using conffile:' . $conffile if $debug;

# Default configuration for all instances
my $uri          = 'ldap+tls://localhost:389/';
my $binddn       = 'cn=Monitor';
my $bindpw       = '';
my $ldap_version = 3;
my $syncrepl     = undef;
my @slapd_instances;

try {
	@slapd_instances = get_Config($conffile);
}
catch {
	croak "ERROR - reading configfile: $_";
};
warn 'D! read this as configuration: ' . Dumper(\@slapd_instances) if $debug;

# Merge config and query each instance:
for my $slapd_instance (@slapd_instances) {
	$slapd_instance->{uri}     //= $uri;
	$slapd_instance->{binddn}  //= $binddn;
	$slapd_instance->{bindpw}  //= $bindpw;
	$slapd_instance->{version} //= $ldap_version;
	if ($slapd_instance->{uri} =~ m{^ldap(s?|\+tls?)://([^/]+)/(.*)$}) {
		$slapd_instance->{secure} //= $1;
		$slapd_instance->{server} //= $2;
		$slapd_instance->{params} //= $3;
	} else {
		croak "ERROR - Could not merge config to a usable form";
	}
	if ($slapd_instance->{params}) {
		croak "ERROR - Plugin does not accept additional Parameters in ldap uri";
	}
	if ($slapd_instance->{server} =~ /\d+\.\d+\.\d+\.\d+/) {
		$slapd_instance->{instancename} //= $slapd_instance->{server};
	} elsif ($slapd_instance->{server} =~ /^(.*?)\./) {
		$slapd_instance->{instancename} //= $1;
	} else {
		$slapd_instance->{instancename} //= $slapd_instance->{server};
	}

	warn 'D! merged configuration to: ' . Dumper($slapd_instance) if $debug;

#
# Do the actual work
#
#	Open Connection to local LDAP:

	my $slave_conn;
	my $master_conn;
	try {
		$slave_conn = get_ldap_connection($slapd_instance->{server}, $slapd_instance->{binddn}, $slapd_instance->{bindpw},
										  $slapd_instance->{secure}, $slapd_instance->{version});
	}
	catch {
		croak "ERROR - $_";
	};

#	Stats local
	try {
		get_stats($slave_conn, $slapd_instance);
	}
	catch {
		croak "ERROR - $_";
	};
#	syncrepl master
# 	TODO Multi Master ?!
	try {
		say "<<<slapd_syncrepl:sep(44)>>>";
		$slapd_instance->{suffix}     //= get_suffix($slave_conn);
		$slapd_instance->{master_uri} //= get_masteruri($slave_conn);
		$master_conn = get_ldap_connection(
										   $slapd_instance->{master_uri}, $slapd_instance->{binddn},
										   $slapd_instance->{bindpw},     $slapd_instance->{secure},
										   $slapd_instance->{version}
		);
		$slapd_instance->{master_suffix} //= get_suffix($master_conn);

		my $slaveCSN  = get_contextcsn($slave_conn,  $slapd_instance->{suffix},        '000');
		my $masterCSN = get_contextcsn($master_conn, $slapd_instance->{master_suffix}, '000');

		my @slavecsn_elts  = parse_csn($slaveCSN);
		my @mastercsn_elts = parse_csn($masterCSN);
		my $deltacsn       = abs($mastercsn_elts[0] - $slavecsn_elts[0]);
		
		say sprintf("%.2f", $deltacsn);

		my $message = $slave_conn->unbind();
		$message->code && croak "could not unbind from server: " . $message->error;
		warn "D! took local connection successfully down: " . $message->code . ', ' . $message->error if $debug;
		$message = $master_conn->unbind();
		$message->code && croak "could not unbind from server: " . $message->error;
		warn "D! took master connection successfully down: " . $message->code . ', ' . $message->error if $debug;
	}
	catch {
		croak "ERROR -  $_";
	};
}
warn "D! successfully finished plugin." if $debug;
exit(0);

########################################################################
########################################################################
# POD

=head1 NAME

slapd_stats.pl - queries slapd's monitoring database  

=head1 SYNOPSIS

    --Timeout,-T    <Timeout> in s, default 3s
    --debug,-d      prints additional output on stderr
    --help,-h,-?    prints this helpmessage

=head1 VERSION

1.0

=cut

