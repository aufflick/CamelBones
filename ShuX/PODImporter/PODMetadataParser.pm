# PODMetadataParser.pm
#
# Copyright 2006 Sherm Pendley

package PODMetadataParser;

use strict;
use warnings;

use Pod::Parser;
use Fcntl qw(:seek);

our @ISA = qw(Pod::Parser);

sub begin_pod {
    my ($parser) = @_;
    $parser->{'name'} = undef;
    $parser->{'name_mode'} = 0;
    $parser->{'text'} = undef;
}

sub command {
	my ($parser, $command, $paragraph, $linenum) = @_;

	my $expansion = $parser->interpolate($paragraph, $linenum);

    if ($command eq 'head1' && $expansion =~ /NAME/) {
        $parser->{'name_mode'} = 1;

    } elsif ($command =~ /head/) {
        $parser->{'name_mode'} = 0;

	} elsif ($command eq 'encoding') {
        if ($parser->{'input_encoding'} eq 'utf8') {
            my $encoding = $paragraph;
            chomp $encoding;
            $parser->{'input_encoding'} = $encoding;
            seek $parser->input_handle(), 0, SEEK_END;
        }
        $expansion = '';
    }

	$parser->{'text'} .= $expansion;
}

sub verbatim {
	my ($parser, $paragraph, $line_num) = @_;

	$parser->{'text'} .= $paragraph;

	if ($parser->{'name_mode'} != 0) {
	   $parser->{'name'} .= $paragraph;
   }
}

sub textblock {
	my ($parser, $paragraph, $line_num) = @_;

	my $expansion = $parser->interpolate($paragraph, $line_num);
	$parser->{'text'} .= $expansion;
	
	if ($parser->{'name_mode'} != 0) {
	   $parser->{'name'} .= $expansion;
   }
}

sub interior_sequence {
	my ($parser, $seq_command, $seq_argument) = @_;

	return $seq_argument;
}
