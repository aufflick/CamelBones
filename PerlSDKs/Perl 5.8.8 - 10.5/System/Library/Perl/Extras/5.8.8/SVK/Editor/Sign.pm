# BEGIN BPS TAGGED BLOCK {{{
# COPYRIGHT:
# 
# This software is Copyright (c) 2003-2006 Best Practical Solutions, LLC
#                                          <clkao@bestpractical.com>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of either:
# 
#   a) Version 2 of the GNU General Public License.  You should have
#      received a copy of the GNU General Public License along with this
#      program.  If not, write to the Free Software Foundation, Inc., 51
#      Franklin Street, Fifth Floor, Boston, MA 02110-1301 or visit
#      their web page on the internet at
#      http://www.gnu.org/copyleft/gpl.html.
# 
#   b) Version 1 of Perl's "Artistic License".  You should have received
#      a copy of the Artistic License with this package, in the file
#      named "ARTISTIC".  The license is also available at
#      http://opensource.org/licenses/artistic-license.php.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of the
# GNU General Public License and is only of importance to you if you
# choose to contribute your changes and enhancements to the community
# by submitting them to Best Practical Solutions, LLC.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with SVK,
# to Best Practical Solutions, LLC, you confirm that you are the
# copyright holder for those contributions and you grant Best Practical
# Solutions, LLC a nonexclusive, worldwide, irrevocable, royalty-free,
# perpetual, license to use, copy, create derivative works based on
# those contributions, and sublicense and distribute those contributions
# and any derivatives thereof.
# 
# END BPS TAGGED BLOCK }}}
package SVK::Editor::Sign;

require SVN::Delta;
use base 'SVK::Editor::ByPass';
use SVK::I18N;
use autouse 'SVK::Util' => qw (tmpfile);

sub add_file {
    my ($self, $path, @arg) = @_;
    my $baton = $self->SUPER::add_file ($path, @arg);
    $self->{filename}{$baton} = $path;
    return $baton;
}

sub open_file {
    my ($self, $path, @arg) = @_;
    my $baton = $self->SUPER::open_file ($path, @arg);
    $self->{filename}{$baton} = $path;
    return $baton;
}

sub close_file {
    my $self = shift;
    my ($baton, $checksum, $pool) = @_;
    push @{$self->{checksum}}, [$checksum, $self->{filename}{$baton}];
    $self->SUPER::close_file (@_);
}

sub close_edit {
    my ($self, $baton) = @_;
    $self->{sig} =_sign_gpg
	(join("\n", "ANCHOR: $self->{anchor}",
	      (map {"MD5 $_->[0] $_->[1]"} @{$self->{checksum}})),'');
    $self->SUPER::close_edit ($baton);
}

sub _sign_gpg {
    my ($plaintext) = @_;
    my $sigfile = tmpfile("sig-", OPEN => 0);
    local *D;
    my $pgp = $ENV{SVKPGP} || 'gpg';
    open D, "| $pgp --clearsign > $sigfile" or die loc("could not call gpg: %1", $!);
    print D $plaintext;
    close D;

    (-e "$sigfile" and -s "$sigfile") or do {
	unlink "$sigfile";
	die loc("cannot find %1, signing aborted", $sigfile);
    };

    open D, "$sigfile" or die loc("cannot open %1: %2", $sigfile, $!);
    local $/;
    my $buf = <D>;
    unlink($sigfile);
    return $buf;
}

1;
