# ShuXParser
#
# Copyright 2005 Sherm Pendley

package ShuXParser;

use strict;
use warnings;

use Pod::Parser;
use Pod::ParseUtils;

use Fcntl qw(:seek);

our @ISA = qw(Pod::Parser);

sub begin_pod {
	my ($parser) = @_;
	my $out_fh = $parser->output_handle();
	print $out_fh <<"EOHTML";
<html>
    <head>
        <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\">
        <base href="file:///">
    </head>
    <body>
EOHTML

	$parser->{'list_types'} = [];
	$parser->{'hide_block'} = 0;
	$parser->{'seen'} = {};
}

sub command {
	my ($parser, $command, $paragraph, $linenum) = @_;

	my $out_fh = $parser->output_handle();
	my $expansion = $parser->interpolate($paragraph, $linenum);

	$expansion =~ s/</&lt;/g;
	$expansion =~ s/####(?!#)/</g;

	if ($command eq 'begin') {
		if ($paragraph eq 'html') {
			$parser->{'hide_block'} = 0;
		} else {
			$parser->{'hide_block'} = 1;
		}
		$expansion = '';

	} elsif ($command eq 'end') {
		$parser->{'hide_block'} = 0;
		$expansion = '';

	} elsif ($parser->{'hide_block'} == 1) {
		$expansion = '';

	} elsif ($parser->{'hide_block'} == 1) {
		$expansion = '';

    } elsif ($command eq 'head1') {
        $expansion = "<h1>$expansion</h1>\n";

	} elsif ($command eq 'head2') {
        if ($expansion =~ /Perl Functions by Category/) {
            $parser->{'is_perlfunc_bycategory'} = 1;
        }
        if ($expansion =~ /Alphabetical Listing of Perl Functions/) {
            $parser->{'is_perlfunc_bycategory'} = 0;
            $parser->{'is_perlfunc_byalpha'} = 1;
        }
		$expansion = "<h2>$expansion</h2>\n";

	} elsif ($command eq 'head3') {
		$expansion = "<h3>$expansion</h3>\n";

	} elsif ($command eq 'head4') {
		$expansion = "<h4>$expansion</h4>\n";

	} elsif ($command eq 'over') {
		$expansion = '';
		push @{$parser->{'list_types'}}, '';

	} elsif ($command eq 'item') {
		my $index = $#{$parser->{'list_types'}};

        if ($parser->{'is_perlfunc_byalpha'}) {
            my ($node) = ($expansion =~ /^(\S+).*/);
            $node =~ s/\W/_/g;

            unless (exists $parser->{'seen'}->{$node}) {
                $parser->{'seen'}->{$node}++;
                $expansion = "<a name='$node'>$expansion</a>";
            }
        }

		if ($parser->{'list_types'}->[$index] eq '') {
			if ($paragraph =~ /\s*\*\s*/) {
				$expansion = '<ul><li>';
				$parser->{'list_types'}->[$index] = '</ul>';
			} elsif ($paragraph =~ /^\s*\d+.*$/) {
				$expansion = '<ol><li>';
				$parser->{'list_types'}->[$index] = '</ol>';
			} else {
				$expansion = "<dl><dt><b>$expansion</b><dd>";
				$parser->{'list_types'}->[$index] = '</dl>';
			}
		} else {
			my $type = $parser->{'list_types'}->[$index];
			if ($type eq '</ul>' || $type eq '</ol>') {
				$expansion = '<li>';
			} else {
				$expansion = "<dt><b>$expansion</b>\n<dd>";
			}
		}

	} elsif ($command eq 'back') {
		if (scalar @{$parser->{'list_types'}}) {
			$expansion = pop @{$parser->{'list_types'}};
		} else {
			warn "Unbalanced over/back";
		}

	} elsif ($command eq 'for') {
		if ($paragraph !~ /html/) {
			$expansion = '';
		}

	} elsif ($command eq 'encoding') {
        if ($parser->{'input_encoding'} eq 'utf8') {
            my $encoding = $paragraph;
            chomp $encoding;
            $parser->{'input_encoding'} = $encoding;
            seek $parser->input_handle(), 0, SEEK_END;
        }
        $expansion = '';
    }

	else { warn "Unknown command $command"; }

	print $out_fh $expansion;
}

sub verbatim {
	my ($parser, $paragraph, $line_num) = @_;

	my $out_fh = $parser->output_handle();
	my $expansion = $paragraph;
	$expansion =~ s/</&lt;/g;

    if ($parser->{'is_main_pod'}) {
        $expansion =~ s/^(\s+)(perl\w+)/$1<a href="$2">$2<\/a>/gm;
    }

	print $out_fh "<pre>$expansion</pre>\n";
}

sub textblock {
	my ($parser, $paragraph, $line_num) = @_;

	my $out_fh = $parser->output_handle();
	my $expansion = $parser->interpolate($paragraph, $line_num);

    if ($expansion =~ /^\s*perl - Practical/) {
        $parser->{'is_main_pod'} = 1;
    }
	$expansion =~ s/</&lt;/g;
	$expansion =~ s/####(?!#)/</g;

	print $out_fh "<p>$expansion</p>\n";
}

sub interior_sequence {
	my ($parser, $seq_command, $seq_argument) = @_;

    if ($parser->{'is_perlfunc_bycategory'} && $seq_command eq 'C') {
        my $node = $seq_argument;
		$node =~ s/\W/_/g;
		return "####a href='#$node'>${seq_argument}####/a>";
    }

	return "####b>${seq_argument}####/b>" if ($seq_command eq 'B');
	return "####i>${seq_argument}####/i>" if ($seq_command eq 'I');
	return "####code>${seq_argument}####/code>" if ($seq_command eq 'C');

	if ($seq_command eq 'E') {
		if ($seq_argument =~ /^[\d]+$/) {
			return "\&#$seq_argument;";
		} elsif ($seq_argument eq 'verbar') {
			return '|';
		} elsif ($seq_argument eq 'sol') {
			return '/';
		} else {
			return "\&$seq_argument;";
		}
	}

	if ($seq_command eq 'F') {
		return "####i>${seq_argument}####/i>";
	}

	if ($seq_command eq 'S') {
		my $arg = $seq_argument;
		$arg =~ s/\s/\&nbsp;/g;
		return $arg;
	}

	if ($seq_command eq 'L') {
	    if ($seq_argument =~ m%^http://%) {
	       return "####a href='$seq_argument'>$seq_argument####/a>";
	    }

		my $link = new Pod::Hyperlink($seq_argument);

		my $page = $link->page();
		my $node = $link->node();
        $node =~ s/\W/_/g;

		my $alt = $link->alttext();
		unless ($alt) {
            if ($page) { $alt = $page; }
            if ($page && $node) { $alt .= ' - '; }
            if ($node) { $alt .= $node; }
        }

		$page =~ s%::%/%g;

		return "####a href='$page#$node'>${alt}####/a>";
	}

	return $seq_argument;
}

sub end_pod {
	my ($parser) = @_;
	my $out_fh = $parser->output_handle();
	print $out_fh '</body></html>';
}
