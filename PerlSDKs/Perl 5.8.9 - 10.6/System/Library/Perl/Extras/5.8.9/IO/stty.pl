#! /usr/bin/perl5.8.9

require IO::Stty;

foreach $param (@ARGV) {
  push (@params,split(/\s/,$param));
}
$stty = IO::Stty::stty(\*STDIN,@params);
if ($stty ne '0 but true') {
  print $stty;
}
