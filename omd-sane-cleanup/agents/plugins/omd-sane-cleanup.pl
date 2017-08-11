#!/usr/bin/env perl

########################################################################
########################################################################
use v5.10;
use strict;
use warnings;
use Getopt::Long;
Getopt::Long::Configure ("bundling");
use Pod::Usage;
use Try::Tiny;
use Data::Dumper;
use Carp;
use DateTime;
use DateTime::Duration;
########################################################################
########################################################################
say "<<<omd-sane-cleanup>>>";


#
# get_Config ('conffile')
## conffile [str]= path to the configfile
#
# returns a hash with the config, or croaks with an error
sub get_Config {
	my ($conffile) = @_;

# Read conffile:
	my $return;
	unless ($return = do $conffile) {
		croak "couldn't parse $conffile: $@" if $@;
		croak "couldn't do $conffile: $!" unless defined $return;
		croak "couldn't run $conffile" unless $return;
	}
	say STDERR "_get_Config: ...parsed Configfile to: ". Dumper($return) if $main::debug >= 2;
	return $return;
}# end get_Config


# _exit(Code, msg)
## Code [int] = exit code
## msg [str] = return message to agent or shell
#
# exits the plugin with the specified parameters, adds ERROR: to the 
# Message, if $Code != 0
sub _exit{
	my ($Code, $str) = @_;
	print "ERROR: " if $Code != 0;
	say $str ."";
	exit($Code);
	
}# end _exit

# clean_FilesByDate(type, files)
## type [str] = a valid DateTime->in_units( type ) value
## files Array[str] = Array of filenames, we rely on the fact that the filename is the creation timestamp
#
# no returncode, but croaks with an error on Failure
sub clean_FilesByDate {
	my ($type, @files) = @_;
	
	my $str = '';
	if ( $type eq 'days' ) { 
		$str = 'filesPerDay';
	} elsif ( $type eq 'months' ) {
		$str = 'daysPerMonth';
	} elsif ( $type eq 'years' ) {
		$str = 'MonthsPerYear';
	} else { 
		croak 'Cant translate Parameter "type"';
	}
	say STDERR "_clean_FilesByDate: ...got: ". Dumper(\$type, \$files[0]) .'(...trunked the files)' if $main::debug >=2;
	#
	# push files to a datastructure that fits our needs
	# Array of Arrays, containing: indices are the $type ago, the content is an Array of filenames
	
	# @structuredFiles = (
	#	# 0 - Today(, this Month, this Year)
	#	  [
	#		# 0
	#		'filename0' # filename is the unixtimestamp of the inventory
	#		# 1
	#		'filename1'
	#		...
	#	  ]
	#	# 1 - Yesterday(, last Month, last Year)
	#	  [ ... ]
	#	...
	# )
	my @structuredFiles = ();
	for my $file ( @files ) {
		my $fileTime = DateTime->from_epoch(epoch => $file);
		#print STDERR '_cleanFilesByDate: ...fileTime: '. $fileTime if $main::debug >=3;
		my $delta;
		if ( $type eq 'days' ) {
			$delta = int($main::now->delta_days($fileTime)->in_units($type));
		} elsif ( $type eq 'months' ) {
			$delta = int($main::now->subtract_datetime($fileTime)->delta_months());
		} else {
			$delta = int(($main::now->subtract_datetime($fileTime)->delta_months() ) / 12);
		}
		#say STDERR ' with delta: '. $delta;
		push @{$structuredFiles[$delta]}, $file;
	}
	say STDERR "_clean_FilesByDate: ...generated datastructure for easier filtering. First Element:".
	           "       ". Dumper($structuredFiles[0]) if $main::debug >=2;
	say STDERR "                    ... rest: ". Dumper(\@structuredFiles) if $main::debug >=3;
	say STDERR '_clean_FilesByDate: ...sorting by Date, removing all except last '. $main::conf->{$str} .' files ($conf->{'. $str .'})' if $main::debug >=3;
	
	my $i = 0;
	for my $arrRef ( @structuredFiles ) {
		next unless defined $arrRef;
    	@{$arrRef} =  sort { $a <=> $b } @{$arrRef};
    	
    	say STDERR '_clean_FilesByDate: ...sorted: '. Dumper($arrRef) if $main::debug >=3 and $i == 0; 
		for ( my $var = 0 ; $var < ($main::conf->{$str}) && scalar @{$arrRef} != 0 ; $var++ ) {
		    my $tmp = pop @{$arrRef};
		    say STDERR "popped ". $tmp if $main::debug >=3 and $i == 0;
		}
		my %cleanedFiles = map { unlink $_; ($_ => $?)  } @{$arrRef};
		say STDERR Dumper(\%cleanedFiles) if $main::debug >=3 and $i == 0;
		$i++;
	}
} # end clean_FilesByDate


########################################################################
########################################################################
# main
#
# Parse options and arguments
GetOptions(
		   'debug|d+'     => \(our $debug = 0),
		   'Timeout|T=i'  => \(our $Timeout = 30),
		   'conffile|c=s' => \(our $conffile = ($ENV{'MK_CONFDIR'} // '/etc/check_mk') . '/omd-sane-cleanup.cfg'),
		   'help|?|h'     => sub {pod2usage(-verbose => 99, -sections => 'NAME|SYNOPSIS|DESCRIPTION|OPTIONS|ARGUMENTS|VERSION')},
) or pod2usage(2); pod2usage(2) if $ARGV[0];
say STDERR "_main: parsed options to:" if $debug >= 1;
say STDERR "_main: debug: ". $debug ."\n".
           "       Timeout: ". $Timeout ."\n". 
           "       config: ". $conffile if $debug >= 1;

# Just in case of problems, let's not hang check_mk_agent
$SIG{'ALRM'} = sub {
	say "Plugin Timed out";
	exit(2);
}; alarm($Timeout);
say STDERR "_main: set script timeout(". $Timeout .")" if $main::debug >= 1;

########################################################################
# initialize some Variables
our $now = DateTime->now;

########################################################################
# Do some sanity checking
_exit(2, 'Environment Variable "OMD_ROOT" not set, we seem to run outside of an omd context') if !$ENV{OMD_ROOT};

########################################################################
# Read conf into $conf
our $conf;
say STDERR "_main: try to parse config from: ". $conffile if $main::debug >= 1;
try {
	$conf = get_Config($conffile);
} catch {
	_exit(2, 'Could not parse Config: '. $_);
};

# chdir to inventory archive:
say STDERR "_main: try to chdir into: ". $conf->{archivePath} if $main::debug >= 1;
try {
	chdir($conf->{archivePath}) || croak $!;
} catch {
	chomp;
	_exit(2, 'Can not change to inventory_archive path ('. $_ .')');
};

# do cleanup for each directory:
my @dirs = <*>;
say STDERR "_main: globed all dirs in inventory_archive, starting cleanup actions, with ". $dirs[0] if $main::debug >= 1;
for my $dir ( @dirs ) {
	
	# each directory gets traversed
	say STDERR "_main: ...processing ". $dir if $main::debug >= 2;
    try {
    	chdir($conf->{archivePath} .'/'. $dir) || croak $!;
    	my @files = <*>;
		say STDERR "_main: ...globed all files (". scalar @files .")" if $main::debug >= 2;
		say STDERR "_main: ...". join(", ", @files) if $main::debug >=3;
		
		for my $type ( qw/days months years/ ) {
			say STDERR '_main: ...try to clean Files by Date filter ('. $type .')' if $main::debug >=2;
			try {
				clean_FilesByDate($type, @files);
			} catch {
				chomp;
				_exit(2, 'Failed to clean Files for '. $dir .': '. $_);
			};
		}
    } catch {
    	chomp;
		_exit(2, 'Failed cleanup for '. $dir .'('. $_ .')');
    };
}




=pod

=encoding latin1

=head1 NAME

omd-sane-cleanup.pl

=head1 SYNOPSIS

omd-sane-cleanup.pl --debug|-d[d...] --Timeout|-T=<int> --config|-c<path to configfile> | [--help|-h|-?]

=head1 DESCRIPTION

This Plugin is actually a scipt to cleanup the omd inventory archive. But it is tightly integrated into check_mk
so it is realized as plugin for the Agent.
The cleanup follows these rules:
1. statisfy the day constraint (e.g. keep last Report per day)
2. statisfy the month constraint (e.g. keep all Reports left from 1. for the last 3 Months)
3. statisfy the year constraint (e.g. keep all Reports left from 1. and 2. for 1 Year)

=head1 OPTIONS

=over 4

=item --help, -h or -?

 Show this help message and exit

=item --debug, -d

 specify multiple times
 Debug Level specifies the verbosity of the script.
 0 is default, does not output any debug
 1 is good enough for most purposes, it just trunkates the Datastructures
 2 is like 1 but with all elements of the Datastructures
 3 not necessary in most cases, could help you develop the script

=item --Timeout, -T

 default: 30 sec

=item --conffile, -c

 default: $ENV{'MK_CONFDIR'} // '/etc/check_mk') . '/omd-sane-cleanup.cfg'
 Path to configfile

=back

=head1 VERSION

1.0.0

=head1 AUTHOR

Markus Weber - markus.weber@lfst.bayern.de

=head1 LICENSE

GPLv2

=cut
