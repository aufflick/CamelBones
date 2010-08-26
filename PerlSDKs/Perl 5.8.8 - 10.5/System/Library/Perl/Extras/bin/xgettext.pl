#!/usr/bin/perl

eval 'exec /usr/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell
use strict;
use Locale::Maketext::Extract::Run 'xgettext';
xgettext(@ARGV);

=head1 NAME

xgettext.pl - Extract translatable strings from source

=head1 SYNOPSIS

B<xgettext.pl> [I<OPTION>] [I<INPUTFILE>]...

=head1 DESCRIPTION

This program extracts translatable strings from given input files, or
from B<STDIN> if none are given.

Please see L<Locale::Maketext::Extract> for a list of supported input file
formats.

=head1 OPTIONS

Mandatory arguments to long options are mandatory for short options too.
Similarly for optional arguments.

=head2 Input file location:

=over 4

=item I<INPUTFILE>...

Files to extract messages from.  If not specified, B<STDIN> is assumed.

=item B<-f>, B<--files-from>=I<FILE>

Get list of input files from I<FILE>.

=item B<-D>, B<--directory>=I<DIRECTORY>

Add I<DIRECTORY> to list for input files search.

=back

=head2 Input file format:

=item B<-u>, B<--use-gettext-style>

Specifies that the source programs uses the B<Gettext> style (e.g.
C<%1>) instead of the B<Maketext> style (e.g. C<[_1]>) in its
localization calls.

=head2 Output file location:

=over 4

=item B<-d>, B<--default-domain>=I<NAME>

Use I<NAME>.po for output, instead of C<messages.po>.

=item B<-o>, B<--output>=I<FILE>

PO file name to be written or incrementally updated; C<-> means writing
to B<STDOUT>.

=item B<-p>, B<--output-dir>=I<DIR>

Output files will be placed in directory I<DIR>.

=back

=head2 Output details:

=over 4

=item B<-g>, B<--gnu-gettext>

Enables GNU gettext interoperability by printing C<#, perl-maketext-format>
before each entry that has C<%> variables.

=back

=head1 SEE ALSO

L<Locale::Maketext::Extract>,
L<Locale::Maketext::Lexicon::Gettext>,
L<Locale::Maketext>

=head1 AUTHORS

Audrey Tang E<lt>cpan@audreyt.orgE<gt>

=head1 COPYRIGHT

Copyright 2002, 2003, 2004 by Audrey Tang E<lt>cpan@audreyt.orgE<gt>.

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
