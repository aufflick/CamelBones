package IO::Pager;

use 5;
use strict;
use vars qw( $VERSION );
use File::Spec;

$VERSION = 0.05;

BEGIN {
  eval 'use File::Which';
  my $which = !$@;
  
  if( defined($ENV{PAGER}) ){
#    my $pager =~ (split(/(?<!\\)\s/, $ENV{PAGER}))[0];
    my $pager = (split(' ', $ENV{PAGER}))[0];
    
    #Some platforms don't do -x so we use -e
    unless( File::Spec->file_name_is_absolute($pager) && -e $pager ){
      if( $which ){
	#In case of non-absolute value
	foreach( File::Which::where($ENV{PAGER}) ){
	  do{ $ENV{PAGER} = $_; last } if -e;
	}
      }
    }
  }
  else{
    my @loc = ( '/usr/local/bin/less',
		'/usr/bin/less',
		'/usr/bin/more' );
    push(@loc, File::Which::where('less'),
	       File::Which::where('more') ) if $which;
    foreach( @loc ) {
      do{ $ENV{PAGER} = $_; last } if -e;
    }
    $ENV{PAGER} ||= 'more';
  }
}

sub new(;$$){
  shift;
  goto &open;
}

sub open(;$$){
  my $class = scalar @_ > 1 ? pop : undef;
  $class ||= 'IO::Pager::Unbuffered';
  eval "require $class";
  $class->new($_[0], $class);
}

1;
__END__
=pod

=head1 NAME

IO::Pager - Select a pager, optionally pipe it output if destination is a TTY

=head1 SYNOPSIS

  #Select a pager, sets $ENV{PAGER}
  use IO::Pager;

  #Optionally pipe output
  {
    #local $STDOUT =     IO::Pager::open *STDOUT;
    local  $STDOUT = new IO::Pager       *STDOUT;
    print <<"  HEREDOC" ;
    ...
    A bunch of text later
    HEREDOC
  }

=head1 DESCRIPTION

IO::Pager is lightweight and can be used to locate an available pager
and set $ENV{PAGER} (see L</NOTES>) or as a factory for creating objects
defined elsewhere such as L<IO::Pager::Buffered> and L<IO::Pager::Unbuffered>.

IO::Pager subclasses are designed to programmatically decide whether
or not to pipe a filehandle's output to a program specified in $ENV{PAGER}.
Subclasses are only required to support filehandle output methods and close,
namely

=over

=item CLOSE

Supports close() of the filehandle.

=item PRINT

Supports print() to the filehandle.

=item PRINTF

Supports printf() to the filehandle.

=item WRITE

Supports syswrite() to the filehandle.

=back

For anything else, YMMV.

=head2 new( [FILEHANDLE], [EXPR] )

Instantiate a new IO::Pager to paginate FILEHANDLE if necessary.
I<Assign the return value to a scoped variable>.

See the appropriate subclass for implementation specific details.

=over

=item FILEHANDLE

Defaults to currently select()-ed FILEHANDLE.

=item EXPR

An expression which evaluates to the subclass of object to create.

Defaults to L<IO::Pager::Unbuffered>.

=back

=head2 open( [FILEHANDLE], [EXPR] )

An alias for new.

=head2 close( FILEHANDLE )

Explicitly close the filehandle, this stops any redirection of output
on FILEHANDLE that may have been warranted. Normally you'd just wait for the
object to pass out of scope.

I<This does not default to the current filehandle>.

See the appropriate subclass for implementation specific details.

=head1 ENVIRONMENT

=over

=item PAGER

The location of the default pager.

=item PATH

If PAGER does not specify an absolute path for the binary PATH may be used.

See L</NOTES> for more information.

=back

=head1 FILES

IO::Pager may fall back to these binaries in order if
I<$ENV{PAGER}> is not executable.

=over

=item /usr/local/bin/less

=item /usr/bin/less

=item /usr/bin/more

=back

See L</NOTES> for more information.

=head1 NOTES

The algorythm for determining which pager is to use as follows:

=over

=item 1. Defer to $ENV{PAGER}

Use the value of $ENV{PAGER} if it exists unless File::Which is available
and the pager in $ENV{PAGER} is determined to be unavailable.

=item 2. Usual suspects

Try the standard, hardcoded paths in L</FILES>.

=item 3. File::Which

If File::Which is available check for C<less> and L<more>.

=item 4. more

Set $ENV{PAGER} to C<more>

=back

Steps 1, 3 and 4 rely upon $ENV{PATH}.

=head1 SEE ALSO

L<IO::Pager::Buffered>, L<IO::Pager::Unbuffered>, L<IO::Pager::Page>

L<IO::Page>, L<Tool::Less>

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
