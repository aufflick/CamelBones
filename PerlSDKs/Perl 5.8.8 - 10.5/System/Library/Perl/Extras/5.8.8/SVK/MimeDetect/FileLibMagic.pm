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
package SVK::MimeDetect::FileLibMagic;
use strict;
use warnings;

use File::LibMagic 0.84 qw( :complete );
use SVK::Util      qw( is_binary_file );

sub new {
    my ($pkg) = @_;

    my $handle = magic_open(MAGIC_MIME);
    magic_load( $handle, "" );    # default magic file

    return bless \$handle, $pkg;
}

sub checktype_filename {
    my ($self, $filename) = @_;

    return 'text/plain' if -z $filename;

    my $type = magic_file( $$self, $filename );
    $type =~ s{ \s* ; \s* charset= .* \z}{}xmsg;    # strip charset info
    return $type if $type ne 'application/octet-stream';

    # verify File::LibMagic's opinion on supposedly binary data
    return 'application/octet-stream' if is_binary_file($filename);
    return 'text/plain';
}

sub DESTROY {
    my ($self) = @_;
    magic_close($$self);
}

1;

__END__

=head1 NAME

SVK::MimeDetect::FileLibMagic

=head1 DESCRIPTION

Implement MIME type detection using the module File::LibMagic

