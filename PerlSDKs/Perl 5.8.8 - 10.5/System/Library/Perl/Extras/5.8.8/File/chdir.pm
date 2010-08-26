package File::chdir;

use 5.004;

use strict;
use vars qw($VERSION @ISA @EXPORT $CWD @CWD);
$VERSION = 0.06;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw($CWD @CWD);

use Cwd;
use File::Spec;

tie $CWD, 'File::chdir::SCALAR' or die "Can't tie \$CWD";
tie @CWD, 'File::chdir::ARRAY'  or die "Can't tie \@CWD";


=head1 NAME

File::chdir - a more sensible way to change directories

=head1 SYNOPSIS

  use File::chdir;

  $CWD = "/foo/bar";     # now in /foo/bar
  {
      local $CWD = "/moo/baz";  # now in /moo/baz
      ...
  }

  # still in /foo/bar!

=head1 DESCRIPTION

Perl's chdir() has the unfortunate problem of being very, very, very
global.  If any part of your program calls chdir() or if any library
you use calls chdir(), it changes the current working directory for
the B<whole> program.

This sucks.

File::chdir gives you an alternative, $CWD and @CWD.  These two
variables combine all the power of C<chdir()>, File::Spec and Cwd.

=head2 $CWD

Use the $CWD variable instead of chdir() and Cwd.

    use File::chdir;
    $CWD = $dir;  # just like chdir($dir)!
    print $CWD;   # prints the current working directory

It can be localized, and it does the right thing.

    $CWD = "/foo";      # it's /foo out here.
    {
        local $CWD = "/bar";  # /bar in here
    }
    # still /foo out here!

$CWD always returns the absolute path.

$CWD and normal chdir() work together just fine.

=head2 @CWD

@CWD represents the current working directory as an array, each
directory in the path is an element of the array.  This can often make
the directory easier to manipulate, and you don't have to fumble with
C<File::Spec-E<gt>splitpath> and C<File::Spec-E<gt>catdir> to make
portable code.

  # Similar to chdir("/usr/local/src/perl")
  @CWD = qw(usr local src perl);

pop, push, shift, unshift and splice all work.  pop and push are
probably the most useful.

  pop @CWD;                 # same as chdir(File::Spec->updir)
  push @CWD, 'some_dir'     # same as chdir('some_dir')

@CWD and $CWD both work fine together.

B<NOTE> Due to a perl bug you can't localize @CWD.  See L</BUGS and
CAVEATS> for a work around.

=cut

sub _abs_path () {
    # Otherwise we'll never work under taint mode.
    my($cwd) = Cwd::abs_path =~ /(.*)/;
    return $cwd;
}

my $Real_CWD;
sub _chdir ($) {
    my($new_dir) = @_;

    my $Real_CWD = File::Spec->catdir(_abs_path(), $new_dir);

    return CORE::chdir($new_dir);
}

{
    package File::chdir::SCALAR;

    sub TIESCALAR { 
        bless [], $_[0];
    }

    # To be safe, in case someone chdir'd out from under us, we always
    # check the Cwd explicitly.
    sub FETCH {
        return File::chdir::_abs_path;
    }

    sub STORE {
        return unless defined $_[1];
        my $did_chdir = File::chdir::_chdir($_[1]);
        return $did_chdir ? $Real_CWD : $did_chdir;
    }
}


{
    package File::chdir::ARRAY;

    sub TIEARRAY {
        bless {}, $_[0];
    }

    # splitdir() leaves empty directory names in place on purpose.
    # I don't think this is the right thing for us, but I could be wrong.
    sub _splitdir {
        return grep length, File::Spec->splitdir($_[0]);
    }

    sub _cwd_list {
        return _splitdir(File::chdir::_abs_path);
    }

    sub _catdir {
        return File::Spec->catdir(File::Spec->rootdir, @_);
    }

    sub FETCH { 
        my($self, $idx) = @_;
        my @cwd = _cwd_list;
        return $cwd[$idx];
    }

    sub STORE {
        my($self, $idx, $val) = @_;

        my @cwd = ();
        if( $self->{Cleared} ) {
            $self->{Cleared} = 0;
        }
        else {
            @cwd = _cwd_list;
        }

        $cwd[$idx] = $val;
        my $dir = _catdir(@cwd);

        my $did_chdir = File::chdir::_chdir($dir);
        return $did_chdir ? $dir : $did_chdir;
    }

    sub FETCHSIZE { return scalar _cwd_list(); }
    sub STORESIZE {}

    sub PUSH {
        my($self) = shift;

        my $dir = _catdir(_cwd_list, @_);
        my $did_chdir = File::chdir::_chdir($dir);
        return $did_chdir ? $self->FETCHSIZE : $did_chdir;
    }

    sub POP {
        my($self) = shift;

        my @cwd = _cwd_list;
        my $popped = pop @cwd;
        my $dir = _catdir(@cwd);
        my $did_chdir = File::chdir::_chdir($dir);
        return $did_chdir ? $popped : $did_chdir;
    }

    sub SHIFT {
        my($self) = shift;

        my @cwd = _cwd_list;
        my $shifted = shift @cwd;
        my $dir = _catdir(@cwd);
        my $did_chdir = File::chdir::_chdir($dir);
        return $did_chdir ? $shifted : $did_chdir;
    }

    sub UNSHIFT {
        my($self) = shift;

        my $dir = _catdir(@_, _cwd_list);
        my $did_chdir = File::chdir::_chdir($dir);
        return $did_chdir ? $self->FETCHSIZE : $did_chdir;
    }

    sub CLEAR  {
        my($self) = shift;
        $self->{Cleared} = 1;
    }

    sub SPLICE {
        my $self = shift;
        my $offset = shift || 0;
        my $len = shift || $self->FETCHSIZE - $offset;
        my @new_dirs = @_;
        
        my @cwd = _cwd_list;
        my @orig_dirs = splice @cwd, $offset, $len, @new_dirs;
        my $dir = _catdir(@cwd);
        my $did_chdir = File::chdir::_chdir($dir);
        return $did_chdir ? @orig_dirs : $did_chdir;
    }

    sub EXTEND { }
    sub EXISTS { 
        my($self, $idx) = @_;
        return $self->FETCHSIZE >= $idx ? 1 : 0;
    }

    sub DELETE {
        die "Even I can't think of what delete \$CWD[\$idx] should do!";
    }
}


=head1 EXAMPLES

(We omit the C<use File::chdir> from these examples for terseness)

Here's $CWD instead of chdir:

    $CWD = 'foo';           # chdir('foo')

and now instead of Cwd.

    print $CWD;             # use Cwd;  print Cwd::abs_path

you can even do zsh style C<cd foo bar>

    $CWD = '/usr/local/foo';
    $CWD =~ s/usr/var/;

if you want to localize that, make sure you get the parens right

    {
        (local $CWD) =~ s/usr/var/;
        ...
    }

It's most useful for writing polite subroutines which don't leave the
program in some strange directory:

    sub foo {
        local $CWD = 'some/other/dir';
        ...do your work...
    }

which is much simplier than the equivalent:

    sub foo {
        use Cwd;
        my $orig_dir = Cwd::abs_path;
        chdir('some/other/dir');

        ...do your work...

        chdir($orig_dir);
    }

@CWD comes in handy when you want to start moving up and down the
directory hierarchy in a cross-platform manner without having to use
File::Spec.

    pop @CWD;                   # chdir(File::Spec->updir);
    push @CWD, 'some', 'dir'    # chdir(File::Spec->catdir(qw(some dir)));

You can easily change your parent directory:

    # chdir from /some/dir/bar/moo to /some/dir/foo/moo
    $CWD[-2] = 'foo';


=head1 BUGS and CAVEATS

C<local @CWD> will not localize C<@CWD>.  This is a bug in Perl, you
can't localize tied arrays.  As a work around localizing $CWD will
effectively localize @CWD.

    {
        local $CWD;
        pop @CWD;
        ...
    }


=head1 NOTES

What should %CWD do?  Something with volumes?

    # chdir to C:\Program Files\Sierra\Half Life ?
    $CWD{C} = '\\Program Files\\Sierra\\Half Life';


=head1 AUTHOR

Michael G Schwern E<lt>schwern@pobox.comE<gt>


=head1 LICENSE

Copyright 2001-2003 by Michael G Schwern E<lt>schwern@pobox.comE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>


=head1 HISTORY

I wanted C<local chdir> to work.  p5p didn't.  Did I let that stop me?
No!  Did we give up after the Germans bombed Pearl Harbor?  Hell, no!

Abigail and/or Bryan Warnock suggested the $CWD thing, I forget which.
They were right.

The chdir() override was eliminated in 0.04.


=head1 SEE ALSO

File::Spec, Cwd, L<perlfunc/chdir>

=cut

1;
