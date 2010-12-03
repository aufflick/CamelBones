#!/usr/bin/perl

use warnings;
use strict;

my $rootdir = $ENV{'BBEditRootDirectory'};
my $file = shift @ARGV;

my %args = @ARGV;
my @expansions;
if (exists $args{'expand'}) {
	@expansions = split(/\s*,\s*/, $args{'expand'});
}

my $menu = [
	{ 'title' => 'Home', 'href' => 'index.html', },
	{ 'title' => 'Getting Started', 'href' => 'docs/getstarted/index.html', },
	{ 'title' => 'Help $upport CamelBones', 'href' => 'http://sourceforge.net/donate/index.php?group_id=48040', },
	{ 'title' => 'Books', 'href' => 'books.html', },
	{ 'title' => 'Documentation', 'href' => 'docs/index.html', 'children' => [
		{ 'title' => 'Getting Started', 'href' => 'docs/getstarted/index.html', 'children' => [
			{ 'title' => 'Hello, Cocoa!', 'href' => 'docs/getstarted/index.html', },
			{ 'title' => 'Responding to Events', 'href' => 'docs/getstarted/events.html', },
			{ 'title' => 'Outlets', 'href' => 'docs/getstarted/outlets.html', },
			{ 'title' => 'The Responder Chain', 'href' => 'docs/getstarted/responderchain.html', },
			{ 'title' => 'Menu Events', 'href' => 'docs/getstarted/menuevents.html', },
		]},
		{ 'title' => 'Concepts', 'href' => 'docs/concepts/index.html', 'children' => [
			{ 'title' => 'Reading Objective-C Documentation', 'href' => 'docs/concepts/readobjc.html', },
			{ 'title' => 'MVC - Model-View-Controller', 'href' => 'docs/concepts/mvc.html', },
			{ 'title' => 'Collections', 'href' => 'docs/concepts/collections.html', },
		]},
		{ 'title' => 'Reference', 'href' => 'docs/ref/index.html', 'children' => [
		    { 'title' => 'Structs', 'href' => 'docs/ref/structs/index.html', 'children' => [
		        { 'title' => 'CamelBones::NSPoint', 'href' => 'docs/ref/structs/nspoint.html', },
		        { 'title' => 'CamelBones::NSRange', 'href' => 'docs/ref/structs/nsrange.html', },
		        { 'title' => 'CamelBones::NSRect', 'href' => 'docs/ref/structs/nsrect.html', },
		        { 'title' => 'CamelBones::NSSize', 'href' => 'docs/ref/structs/nssize.html', },
		    ]},
		    { 'title' => 'Method Signatures', 'href' => 'docs/ref/typesigs.html', },
		]},
		{ 'title' => 'Subversion access', 'href' => 'docs/subversion-access.html', },
	]},
	{ 'title' => 'Downloads', 'href' => 'https://sourceforge.net/projects/camelbones/files/camelbones/', },
	{ 'title' => 'Sourceforge Project', 'href' => 'https://sourceforge.net/projects/camelbones/', },
	{ 'title' => 'Contact Info', 'href' => 'contact.html', },
	{ 'title' => 'Copyright &amp; License', 'href' => 'copyright.html', },
];

print <<'EOF';
<div id="menu">
EOF

print_menu($menu, 0);

print <<'EOF';
<div id="menu_title">
    <a id="toggle_menu" href="#"><span id="menu_status"></span></a>
</div>
</div>  <!-- menu -->
EOF

sub print_menu {
	my ($menu, $indent) = @_;

	$indent and print "\n";
	print '    ' x $indent, '<ul';
	$indent or print ' id="menulist"';
	print ">\n";

	foreach my $item (@$menu) {
		print '    ' x ($indent + 1), '<li>';
		
		if ( exists $item->{'href'} && $item->{'href'} =~ /^https?:/ ) {
			print '<a href="', $item->{'href'}, '">', $item->{'title'}, '</a>';
		} elsif (exists $item->{'href'} && $file ne $rootdir."/".$item->{'href'}) {
			print '<a href="#relative#', $item->{'href'}, '">', $item->{'title'}, '</a>';
		} else {
			print $item->{'title'};
		}
		
		if (exists $item->{'children'} &&
			exists $item->{'href'} &&
			grep { $item->{'href'} =~ m%^$_/\w+.html% } @expansions)
		{
			print_menu($item->{'children'}, $indent + 2);
			print '    ' x ($indent + 1);
		}
		print "</li>\n";
	}
	
	print '    ' x $indent, "</ul>\n";
}
