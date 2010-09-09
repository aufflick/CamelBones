package IO::Pager::Page;
use vars '$VERSION';

$VERSION = 0.05;

#The meat
BEGIN{
  use IO::Pager;
  new IO::Pager *STDOUT;
}

#Gravy
sub import{
  shift;
  my %opt = @_;
  $SIG{PIPE} = sub{ exit 0; } if $opt{hush};
}

"Badee badee badee that's all folks!";
__END__

=head1 NAME

IO::Pager::Page - use IO::Pager to emulate IO::Page, pipe STDOUT to a pager if STDOUT is a TTY

=head1 SYNOPSIS

Pipes STDOUT to a pager if STDOUT is a TTY

=head1 DESCRIPTION

IO::Pager is designed to programmaticly decide whether or not to point
the STDOUT file handle into a pipe to program specified in $ENV{PAGER}
or one of a standard list of pagers.

=head1 USAGE

  BEGIN{
    use IO::Pager::Page;
    #use I::P::P first, just in case another module sends output to STDOUT
  }
  print<<HEREDOC;
  ...
  A bunch of text later
  HEREDOC

If you wish to forgo the potential for a I<Broken Pipe> foible resulting
from the user exiting the pager prematurely load IO::Pager::Page like so:

  use IO::Pager::Page hush=>1;

=head1 SEE ALSO

L<IO::Page>, L<IO::Pager>, L<IO::Pager::Unbuffered>, L<IO::Pager::Buffered>

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

=head1 LICENSE

=over

=item * Thou shalt not claim ownership of unmodified materials.

=item * Thou shalt not claim whole ownership of modified materials.

=item * Thou shalt grant the indemnity of the provider of materials.

=item * Thou shalt use and dispense freely without other restrictions.

=back

=cut
