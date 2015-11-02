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

#	'statistics_bytes'
#     => {
#         'search' => "cn=Bytes,cn=Statistics",
#         'desc'   => "The number of bytes sent by the LDAP server.",
#         'vlabel' => 'Bytes pr ${graph_period}',
#         'label'  => 'Bytes',
#         'title'  => "Number of bytes sent",
#         'info'   => "The graph shows the number of bytes sent",
#	 'scope'  => "base"
#         },
#     'statistics_pdu'
#     => {
#         'search' => "cn=PDU,cn=Statistics",
#         'desc'   => "The number of PDUs sent by the LDAP server.",
#         'vlabel' => 'PDUs pr ${graph_period}',
#         'label'  => 'PDUs',
#         'title'  => "Number of PDUs sent",
#         'info'   => "The graph shows the number of PDUs sent",
#	 'scope'  => "base"
#         },
#     # Referrals
#     'statistics_referrals'
#     => {
#         'search' => "cn=Referrals,cn=Statistics",
#         'desc'   => "The number of Referrals sent by the LDAP server.",
#         'vlabel' => 'Referrals pr ${graph_period}',
#         'label'  => 'Referrals',
#         'title'  => "Number of LDAP Referrals",
#         'info'   => "The graph shows the number of referrals sent",
#	 'scope'  => "base"
#         },
#     # Entries
#     'statistics_entries'
#     => {
#         'search' => "cn=Entries,cn=Statistics",
#         'desc'   => "The number of Entries sent by the LDAP server.",
#         'vlabel' => 'Entries pr ${graph_period}',
#         'label'  => 'Entries',
#         'title'  => "Number of LDAP Entries",
#         'info'   => "The graph shows the number of entries sent",
#	 'scope'  => "base"
#         },
# read Current and Total Connections
	'connections' => {
					   'search' => 'cn=Connections,cn=Monitor',
					   'filter' => '(&(objectclass=*)(|(cn=Current)(cn=Total)))',
					   'attrs'  => ['monitorCounter', 'cn'],
					   'scope'  => "one",
					   'title'  => 'Number of Connections',
					   'info'   => 'Number of connections to the LDAP server',
	},

# dn: cn=Write,cn=Waiters,cn=Monitor
# dn: cn=Read,cn=Waiters,cn=Monitor
	'waiters' => {
				   'search' => 'cn=Waiters,cn=Monitor',
				   'filter' => '(&(objectclass=*)(|(cn=Write)(cn=Read)))',
				   'attrs'  => ['monitorCounter', 'cn'],
				   'scope'  => 'one',
				   'title'  => "Number of Waiters",
				   'info'   => "The graph shows the number of Waiters",
	},
	'operations' => {
		'search' => "cn=Operations,cn=Monitor",
		'filter' => '(objectclass=*)',
		'attrs' => ['monitorOpInitiated', 'monitorOpCompleted', 'cn'],
		'scope' => 'one',
		'title' => "Operations",
		'info'  => "Number of completed LDAP operations",
	}
);

########################################################################
########################################################################
# functions

sub get_ldap_connection {
	my $slapd_instance = $_[0];

#my $ldap = Net::LDAP->new( $slapd_instance->{server}, port => $slapd_instance->{port} , onerror => 'die' , version => 3  ) or die "could not connect to LDAP Server: $@";
	my $ldap = Net::LDAP->new($slapd_instance->{server}, version => $slapd_instance->{version})
	  or die "could not connect to LDAP Server: $@";
	warn "D! successfully connected to LDAP Server: $slapd_instance->{server}" if $debug;

	if ($slapd_instance->{secure} eq '+tls') {
		my $message = $ldap->start_tls();
		$message->code && croak "could not start tls: " . $message->error;
		warn "D! successfully used start_tls: " . $message->code . ', ' . $message->error if $debug;
	}

# Bind witch credentials if specified or anonymously if either password or binddn is missing
	if ($slapd_instance->{binddn} && $slapd_instance->{bindpw}) {
		my $req_bind = $ldap->bind($slapd_instance->{binddn}, password => $slapd_instance->{bindpw});
		$req_bind->code && croak "could not bind as $slapd_instance->{binddn} : " . $req_bind->error;
		warn "D! successfully bound to ldap server as $slapd_instance->{binddn} : " . $req_bind->code . ", " . $req_bind->error
		  if $debug;
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
		for my $fetched_attr (@{$query->{attrs}}) {
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
	my $slapd_instance = $_[0];
	my $conn;
	my $output;

# establish connection and use it for all queries in get_value function
	try {
		$conn = get_ldap_connection($slapd_instance);
	}
	catch {
# TODO better errorhandling...
		say $_;
		exit(2);
	};

# get_values for all keys in global_vars and print them line by line or print errormessage
	for my $what (keys %global_vars) {
		try {
			my $fetched = get_value($conn, $global_vars{$what});
			for my $key (keys %{$fetched}) {
				say $slapd_instance->{instancename} . "," . $what . ":" . $key . ":" . join(',', @{ $fetched->{$key} });
			}
		}
		catch {
			say $slapd_instance->{instancename} . "," . $what . ":" . $_;
		};
	}

	try {
		my $message = $conn->unbind();
		$message->code && croak "could not unbind from server: " . $message->error;
		warn "D! took connection successfully down: " . $message->code . ', ' . $message->error if $debug;
	}
	catch {
# TODO better errorhandling...
		say $_;
		exit(2);
	};
}    # END get_stats

########################################################################
########################################################################
# main

my $conffile = ($ENV{'MK_CONFDIR'} // '/etc/check_mk') . '/slapd_stats.cfg';
warn 'D! using conffile:' . $conffile if $debug;

# Default configuration for all instances
my $uri          = 'ldap+tls://localhost:389/';
my $binddn       = 'cn=Monitor';
my $bindpw       = '';
my $ldap_version = 3;

# Read conffile:
unless (my $return = do $conffile) {
	warn "couldn't parse $conffile: $@" if $@;
	warn "couldn't do $conffile: $!" unless defined $return;
	warn "couldn't run $conffile" unless $return;
}
our @slapd_instances;
warn 'D! read this as configuration: ' . Dumper(\@slapd_instances) if $debug;

say "<<<slapd_stats>>>";

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
		say "Could not merge config to a usable form";
		exit(2);
	}
	if ($slapd_instance->{params}) {
		say "Plugin does not accept additional Parameters in ldap uri";
		exit(2);
	}
	if ($slapd_instance->{server} =~ /\d+\.\d+\.\d+\.\d+/) {
		$slapd_instance->{instancename} //= $slapd_instance->{server};
	} elsif ($slapd_instance->{server} =~ /^(.*?)\./) {
		$slapd_instance->{instancename} //= $1;
	} else {
		$slapd_instance->{instancename} //= $slapd_instance->{server};
	}

	warn 'D! merged configuration to: ' . Dumper($slapd_instance) if $debug;

	try {
		get_stats($slapd_instance);
	}
	catch {
		say "something bad happened: $_";
		exit(2);
	};
}
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

