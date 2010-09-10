use strict;
use warnings;

package CamelBones::Tests;
use CamelBones;

@CBExceptionTests::ISA = qw(NSObject);
@CBStructureTests::ISA = qw(NSObject);
@CBThreadTests::ISA = qw(NSObject);
@CBSuper::ISA = qw(NSObject);

require Exporter;
our @ISA = qw(Exporter);
our $VERSION = $CamelBones::VERSION;
our @EXPORT = qw(
				 cbt_isNil
				 cbt_char2string
				 cbt_uchar2string
				 cbt_int2string
				 cbt_uint2string
				 cbt_long2string
				 cbt_ulong2string
);
our @EXPORT_OK = (	
                );
our %EXPORT_TAGS = (
    'All'		=> [@EXPORT_OK],
);

require XSLoader;
XSLoader::load('CamelBones::Tests');

1;
