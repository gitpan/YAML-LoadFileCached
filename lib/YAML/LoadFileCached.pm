package YAML::LoadFileCached;

#
# $Id: LoadFileCached.pm,v 1.2 2002/08/01 15:07:08 fhe Exp $
#

use 5.006;
use strict;
use warnings;

use YAML qw(LoadFile);

require Exporter;

our @ISA	= qw(Exporter);
our @EXPORT_OK	= qw(
	CacheStatistics
	);
our @EXPORT	= qw(
	LoadFileCached
	);
our $VERSION	= '0.20';

my $cache;
my $statistic;

sub LoadFileCached
	{
	my($filepath)	= @_;

	return undef unless defined $filepath;

	if(exists($cache->{$filepath}) && ($statistic->{$filepath}->{'lastchanged'} == (stat($filepath))[9]))
		{
		$statistic->{$filepath}->{'cached'}++;
		}
	else
		{
		$cache->{$filepath} = LoadFile($filepath);
				
		$statistic->{$filepath}->{'lastchanged'} = (stat($filepath))[9];
		$statistic->{$filepath}->{'read'}++;
		}

	return $cache->{$filepath};
	}


sub CacheStatistics
	{
	my ($filepath)	= @_;

	return $statistic unless defined $filepath;

	return exists($statistic->{$filepath}) ? $statistic->{$filepath} : undef;
	}


1;
__END__

=head1 NAME

YAML::LoadFileCached - A wrapper around YAML::LoadFile with caching
capabilities.

=head1 SYNOPSIS

  use YAML::LoadFileCached;
  use Data::Dumper;

  my $data = LoadFileCached('data.yaml');

  print Dumper($data);

=head1 DESCRIPTION

This module provides a way to gain speed improvements when you have
to repeatedly read a file in YAML format (eg. configuration files)
under mod_perl or in a long running process, although at the cost
of memory expense.

The by default exported function B<LoadFileCached> caches the results
from B<YAML::LoadFile> and simply returns them if called repeatedly.

If the requested file has been changed since the last request,
B<LoadFileCached> will reread it.

=head1 FUNCTIONS

=over 4

=item B<LoadFileCached> (I<filepath>)

see DISCRIPTION.

=item B<CacheStatistics> ([I<filepath>])

this by default not exported function returns statistics for the
cache used by B<LoadFileCached>. If given I<filepath> it returns
a Hashref with the keys:

=over 6

=item I<lastchanged>

the last modify time in seconds since the epoch (as retourned by
C<stat>).

=item I<read>

number of calls to B<YAML::LoadFile>.

=item I<cached>

number of cache-served requests.

=back

If called with no argument, B<CacheStatistics> returns a Hash
of Hashrefs with I<filepath> as key in the first level.

=back

=head1 AUTHOR

Florian Helmberger, E<lt>fh@laudatio.comE<gt>

=head1 SEE ALSO

L<YAML>.

=cut
