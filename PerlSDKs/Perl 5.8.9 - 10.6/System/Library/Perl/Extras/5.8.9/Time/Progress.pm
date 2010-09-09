package Time::Progress;
use Exporter;
our @ISA = qw( Exporter );
our @EXPORT = qw(  );
our $VERSION = '1.4';
use strict;
use warnings;
use Carp;

our %ATTRS =  (
              min => 1,
              max => 1,
              format => 1,
              );

sub new
{
  my $class = shift;
  my $self = { min => 0, max => 100 };
  bless $self;
  $self->attr( @_ );
  $self->restart();
  return $self;
}

sub attr
{
  my $self = shift;
  croak "bad number of attribute/value pairs" unless @_ == 0 or @_ % 2 == 0;
  my @ret;
  my %h = @_;
  for( keys %h )
    {
    croak "invalid attribute name: $_" unless $ATTRS{ $_ };
    $self->{ $_ } = $h{ $_ } if defined $h{ $_ };
    push @ret, $self->{ $_ };
    }
  return @ret;
}

sub restart
{
  my $self = shift;
  my @ret = $self->attr( @_ );
  $self->{ 'start' } = time();
  $self->{ 'stop'  } = undef;
  return @ret;
}

sub stop
{
  my $self = shift;
  $self->{ 'stop'  } = time();
}

sub continue
{
  my $self = shift;
  $self->{ 'stop'  } = undef;
}

sub report
{
  my $self = shift;
  my $format = shift || $self->{ 'format' };
  my $cur = shift;

  my $start = $self->{ 'start' };

  my $now = $self->{ 'stop' } || time();

  croak "use restart() first" unless $start > 0;
  croak "time glitch (running backwards?)" if $now < $start;
  croak "empty format, use format() first" unless $format;

  my $l = $now - $start;
  my $L = sprintf "%3d:%02d", int( $l / 60 ), ( $l % 60 );

  my $min = $self->{ 'min' };
  my $max = $self->{ 'max' };
  $cur = $min unless defined $cur;

  my $b  = 'n/a';
  my $bl = 79;

  if ( $format =~ /%(\d*)[bB]/ )
    {
    $bl = $1;
    $bl = 79 if $bl eq '' or $bl < 1;
    }

  my $e = "n/a";
  my $E = "n/a";
  my $f = "n/a";
  my $p = "n/a";

  if ( (($min <= $cur and $cur <= $max) or ($min >= $cur and $cur >= $max)) )
    {
    if ( $cur - $min == 0 )
      {
      $e = 0;
      }
    else
      {
      $e = $l * ( $max - $min ) / ( $cur - $min );
      $e = int( $e - $l );
      $e = 0 if $e < 0;
      }
    $E = sprintf "%3d:%02d", int( $e / 60 ), ( $e % 60 );

    $f = $now + $e;
    $f = localtime( $f );

    if ( $max - $min != 0 )
      {
      $p = 100 * ( $cur - $min ) / ( $max - $min );
      $b = '#' x int( $bl * $p / 100 ) . '.' x $bl;
      $b = substr $b, 0, $bl;
      $p = sprintf "%5.1f%%", $p;
      }
    }

  $format =~ s/%l/$l/g;
  $format =~ s/%L/$L/g;
  $format =~ s/%e/$e/g;
  $format =~ s/%E/$E/g;
  $format =~ s/%p/$p/g;
  $format =~ s/%f/$f/g;
  $format =~ s/%\d*[bB]/$b/g;

  return $format;
}

sub elapsed
{ my $self = shift; return $self->report("%l"); }

sub elapsed_str
{ my $self = shift; return $self->report("elapsed time is %L min.\n"); }

sub estimate
{ my $self = shift; return $self->report("%e"); }

sub estimate_str
{ my $self = shift; return $self->report("remaining time is %E min.\n"); }

1;

=pod

=head1 NAME

Time::Progress - Elapsed and estimated finish time reporting.

=head1 SYNOPSIS

  use Time::Progress;
  # autoflush to get \r working
  $| = 1;
  # get new `timer'
  my $p = new Time::Progress;

  # restart and report progress
  $p->restart;
  sleep 5; # or do some work here
  print $p->report( "done %p elapsed: %L (%l sec), ETA %E (%e sec)\n", 50 );

  # set min and max values
  $p->attr( min => 2, max => 20 );
  # restart `timer'
  $p->restart;
  my $c;
  for( $c = 2; $c <= 20; $c++ )
    {
    # print progress bar and percentage done
    print $p->report( "eta: %E min, %40b %p\r", $c );
    sleep 1; # work...
    }
  # stop timer
  $p->stop;

  # report times
  print $p->elapsed_str;

=head1 DESCRIPTION

Shortest time interval that can be measured is 1 second. The available methods are:

=over 4

=item new

  my $p = new Time::Progress;

Returns new object of Time::Progress class and starts the timer. It
also sets min and max values to 0 and 100, so the next B<report> calls will
default to percents range.

=item restart

restarts the timer and clears the stop mark. optionally restart() may act also
as attr() for setting attributes:

  $p->restart( min => 1, max => 5 );

is the same as:

  $p->attr( min => 1, max => 5 );
  $p->restart();

If you need to count things, you can set just 'max' attribute since 'min' is
already set to 0 when object is constructed by new():

  $p->restart( max => 42 );

=item stop

Sets the stop mark. this is only usefull if you do some work, then finish,
then do some work that shouldn't be timed and finally report. Something
like:

  $p->restart;
  # do some work here...
  $p->stop;
  # do some post-work here
  print $p->report;
  # `post-work' will not be timed

Stop is useless if you want to report time as soon as work is finished like:

  $p->restart;
  # do some work here...
  print $p->report;

=item continue

Clears the stop mark. (mostly useless, perhaps you need to B<restart>?)

=item attr

Sets and returns internal values for attributes. Available attributes are:

=over 4

=item min

This is the min value of the items that will follow (used to calculate
estimated finish time)

=item max

This is the max value of all items in the even (also used to calculate
estimated finish time)

=item format

This is the default B<report> format. It is used if B<report> is called
without parameters.

=back

B<attr> returns array of the set attributes:

  my ( $new_min, $new_max ) = $p->attr( min => 1, max => 5 );

If you want just to get values use undef:

  my $old_format = $p->attr( format => undef );

This way of handling attributes is a bit heavy but saves a lot
of attribute handling functions. B<attr> will complain if you pass odd number
of parameters.

=item report

B<report> is the most complex method in this package! :)

expected arguments are:

  $p->report( format, [current_item] );

I<format> is string that will be used for the result string. Recognized
special sequences are:

=over 4

=item %l

elapsed seconds

=item %L

elapsed time in minutes in format MM:SS

=item %e

remaining seconds

=item %E

remaining time in minutes in format MM:SS

=item %p

percentage done in format PPP.P%

=item %f

estimated finish time in format returned by B<localtime()>

=item %b

=item %B

progress bar which looks like:

  ##############......................

%b takes optional width:

  %40b -- 40-chars wide bar
  %9b  --  9-chars wide bar
  %b   -- 79-chars wide bar (default)

=back

Parameters can be ommited and then default format set with B<attr> will
be used.

Estimate time calculations can be used only if min and max values are set
(see B<attr> method) and current item is passed to B<report>! if you want
to use the default format but still have estimates use it like this:

  $p->format( undef, 45 );

If you don't give current item (step) or didn't set proper min/max value
then all estimate sequences will have value `n/a'.

You can freely mix reports during the same event.

=item elapsed

=item estimated

=item elapsed_str

=item estimated_str

helpers -- return elapsed/estimated seconds or string in format:

  "elapsed time is MM:SS min.\n"
  "remaining time is MM:SS min.\n"

=back

=head1 FORMAT EXAMPLES

  # $c is current element (step) reached
  # for the examples: min = 0, max = 100, $c = 33.3

  print $p->report( "done %p elapsed: %L (%l sec), ETA %E (%e sec)\n", $c );
  # prints:
  # done  33.3% elapsed time   0:05 (5 sec), ETA   0:07 (7 sec)

  print $p->report( "%45b %p\r", $c );
  # prints:
  # ###############..............................  33.3%

  print $p->report( "done %p ETA %f\n", $c );
  # prints:
  # done  33.3% ETA Sun Oct 21 16:50:57 2001

=head1 AUTHOR

  Vladi Belperchinov-Shabanski "Cade"

  <cade@biscom.net> <cade@datamax.bg> <cade@cpan.org>

  http://cade.datamax.bg

=cut
