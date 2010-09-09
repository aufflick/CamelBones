package SVN::Dump::Reader;

use strict;
use warnings;
use IO::Handle;
use Carp;

our @ISA = qw( IO::Handle );

# SVN::Dump elements
use SVN::Dump::Headers;
use SVN::Dump::Property;
use SVN::Dump::Text;
use SVN::Dump::Record;

# some useful definitions
my $NL = "\012";

# the object is a filehandle
sub new {
    my ($class, $fh) = @_;
    croak 'SVN::Dump::Reader parameter is not a filehandle'
        if !( $fh && ref $fh && ref($fh) eq 'GLOB' );
    return bless $fh, $class;
}

sub read_record {
    my ($fh) = @_;

    # no more records?
    return if eof($fh);

    my $record = SVN::Dump::Record->new();

    # first get the headers
    my $headers = $fh->read_header_block();
    $record->set_headers_block( $headers );
    
    # get the property block
    $record->set_property_block( $fh->read_property_block() )
        if exists $headers->{'Prop-content-length'};

    # get the text block
    $record->set_text_block(
        $fh->read_text_block( $headers->{'Text-content-length'} ) )
        if exists $headers->{'Text-content-length'};

    # some safety checks
    croak "Inconsistent record size"
        if ( $headers->{'Prop-content-length'} || 0 )
        + ( $headers->{'Text-content-length'} || 0 )
        != ( $headers->{'Content-length'} || 0 );

    # if we have a delete record with a 'Node-kind' header
    # we have to recurse for an included record
    if (   exists $headers->{'Node-action'}
        && $headers->{'Node-action'} eq 'delete'
        && exists $headers->{'Node-kind'} )
    {
        my $included = $fh->read_record();
        $record->set_included_record( $included );
        <$fh>; # chop the empty line that follows
    }

    # chop empty line after the record
    my $type = $headers->type();
    <$fh> if $type !~ /\A(?:format|uuid)\z/;

    # chop another one after a node with only a prop block
    <$fh> if $type eq 'node' && $record->has_prop_only();

    # uuid and format record only contain headers
    return $record;
}

sub read_header_block {
    my ($fh) = @_;

    local $/ = $NL;
    my $headers = SVN::Dump::Headers->new();
    while(1) {
        my $line = <$fh>;
        croak _eof() if !defined $line;
        chop $line;
        last if $line eq ''; # stop on empty line

        my ($key, $value) = split /: /, $line, 2;
        $headers->{$key} = $value;
    }

    croak "Empty line found instead of a header block line $."
       if ! keys %$headers;

    return $headers;
}

sub read_property_block {
    my ($fh) = @_;
    my $property = SVN::Dump::Property->new();

    local $/ = $NL;
    my @buffer;
    while(1) {
        my $line = <$fh>;
        croak _eof() if !defined $line;
        chop $line;

        # read a key/value pair
        if( $line =~ /\AK (\d+)\z/ ) {
            my $key = '';
            $key .= <$fh> while length($key) < $1;
            chop $key; # remove the last $NL

            $line = <$fh>;
            croak _eof() if !defined $line;
            chop $line;
         
            if( $line =~ /\AV (\d+)\z/ ) {
                my $value = '';
                $value .= <$fh> while length($value) <= $1;
                chop $value; # remove the last $NL

                $property->set( $key => $value );

                # FIXME what happens if we see duplicate keys?
            }
            else {
                croak "Corrupted property"; # FIXME better error message
            }
        }
        # or a deleted key (only with fs-format-version >= 3)
        # FIXME shall we fail if fs-format-version < 3?
        elsif( $line =~ /\AD (\d+)\z/ ) {
            my $key = '';
            $key .= <$fh> while length($key) < $1;
            chop $key; # remove the last $NL
            
            $property->set( $key => undef ); # undef means deleted
        }
        # end of properties
        elsif( $line =~ /\APROPS-END\z/ ) {
            last;
        }
        # inconsistent data
        else {
            croak "Corrupted property"; # FIXME better error message
        }
    }

    return $property;
}

sub read_text_block {
    my ($fh, $size) = @_;

    local $/ = $NL;

    my $text = '';
    while( length($text) <= $size ) {
        my $line = <$fh>;
        croak _eof() if ! defined $line;
        $text .= $line;
    }

    # remove extra $NL
    chop $text while length($text) > $size;

    return SVN::Dump::Text->new( $text );
}

# FIXME make this more explicit
sub _eof { return "Unexpected EOF line $.", }

__END__

=head1 NAME

SVN::Dump::Reader - A Subversion dump reader

=head1 SYNOPSIS

    # !!! You should use SVN::Dump, not SVN::Dump::Reader !!!

    use SVN::Dump::Reader;
    my $reader = SVN::Dump::Reader( $fh );
    my $record = $reader->read_record();

=head1 DESCRIPTION

The C<SVN::Dump::Reader> class implements a reader object for Subversion
dumps.

=head1 METHODS

The following methods are available:

=over 4

=item new( $fh )

Create a new C<SVN::Dump::Reader> attached to the C<$fh> filehandle.

=item read_record( )

Read and return a new S<SVN::Dump::Record> object from the dump filehandle.

=item read_header_block( )

Read and return a new S<SVN::Dump::Headers> object from the dump filehandle.

=item read_property_block( )

Read and return a new S<SVN::Dump::Property> object from the dump filehandle.

=item read_text_block( )

Read and return a new S<SVN::Dump::Text> object from the dump filehandle.

=back

The C<read_...> methods will die horribly if asked to read inconsistent
data from a stream.

=head1 SEE ALSO

L<SVN::Dump>, L<SVN::Dump::Headers>, L<SVN::Dump::Property>,
L<SVN::Dump::Text>.

=head1 COPYRIGHT & LICENSE

Copyright 2006 Philippe 'BooK' Bruhat, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

