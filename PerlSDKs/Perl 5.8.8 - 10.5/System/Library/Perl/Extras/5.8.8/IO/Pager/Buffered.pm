package IO::Pager::Buffered;

use 5;
use strict;
use vars qw( $VERSION );
use Tie::Handle;

$VERSION = 0.03;

sub new(;$){
  no strict 'refs';
  my $FH = $_[1] || *{select()};

  #STDOUT & STDERR are seperately bound to tty
  if( defined( my $FHn = fileno($FH) ) ){
    if( $FHn == fileno(STDOUT) ){
      return 0 unless -t $FH;
    }
    if( $FHn == fileno(STDERR) ){
      return 0 unless -t $FH;
    }
  }
  #This allows us to have multiple pseudo-STDOUT
  return 0 unless -t STDOUT;

  tie($FH, $_[0], $FH) or die "Can't tie $$FH";
}

sub open(;$){
  new IO::Pager::Buffered;
}

sub TIEHANDLE{
  bless [$_[1], '', 0], $_[0];
}

sub PRINT{
  my $ref = shift;
  $ref->[1] .= join($,||'', @_);
}

sub PRINTF{
  PRINT shift, sprintf shift, @_;
}

sub WRITE{
  PRINT shift, substr $_[0], $_[2]||0, $_[1];
}


*DESTROY = *CLOSE;
sub CLOSE{
  local $^W = 0;
  my $ref = $_[0];
  return if $ref->[2]++;
  untie $ref->[0];

  CORE::open(PAGER, "| $ENV{PAGER}") ?
    do{ print PAGER $ref->[1]; close PAGER; } : 
    do{ warn -x $ENV{PAGER} ? "Can't pipe to $ENV{PAGER}: $!\n" :
	  "Couldn't find a pager!\n"; print $ref->[1]; }
}

1;
__END__
=pod

=head1 NAME

IO::Pager::Buffered - Pipe deferred output to a pager if output is to a TTY

=head1 SYNOPSIS

  use IO::Pager::Buffered;
  {
    #local $STDOUT =     IO::Pager::Buffered::open *STDOUT;
    local  $STDOUT = new IO::Pager::Buffered       *STDOUT;
    print <<"  HEREDOC" ;
    ...
    A bunch of text later
    HEREDOC
  }

=head1 DESCRIPTION

IO::Pager is designed to programmaticly decide whether or not to point
the STDOUT file handle into a pipe to program specified in $ENV{PAGER}
or one of a standard list of pagers.

This subclass buffers all output for display upon exiting the current scope.
If this is not what you want look at another subclass such as
L<IO::Pager::Unbuffered>. While probably not common, this may be useful in
some cases,such as buffering all output to STDOUT while the process occurs,
showing only warnings on STDERR, then displaying the output to STDOUT after.
Or alternately letting output to STDERR slide by and defer warnings for later
perusal.

=head2 new( [FILEHANDLE] )

Instantiate a new IO::Pager to paginate FILEHANDLE if necessary.
I<Assign the return value to a scoped variable>. Output does not
occur until all references to this variable are destroyed eg;
upon leaving the current scope. See L</DESCRIPTION>.

=over

=item FILEHANDLE

Defaults to currently select()-ed FILEHANDLE.

=back

=head2 open( [FILEHANDLE] )

An alias for new.

=head2 close( FILEHANDLE )

Explicitly close the filehandle, this stops collecting and displays the
output, executing a pager if necessary. Normally you'd just wait for the
object to pass out of scope.

I<This does not default to the current filehandle>.

=head1 CAVEATS

If you mix buffered and unbuffered operations the output order is unspecified,
and will probably differ for a TTY vs. a file. See L<perlfunc>.

I<$,> is used see L<perlvar>.

=head1 SEE ALSO

L<IO::Pager>, L<IO::Pager::Unbuffered>, L<IO::Pager::Page>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

This module is forked from IO::Page 0.02 by Monte Mitzelfelt

=head1 LICENSE

=over

=item * Thou shalt not claim ownership of unmodified materials.

=item * Thou shalt not claim whole ownership of modified materials.

=item * Thou shalt grant the indemnity of the provider of materials.

=item * Thou shalt use and dispense freely without other restrictions.

=back

=cut
