These are Perl installs copied from various Mac OS X releases.

The 5.8.1RC1 (Panther) package is optional and not selected by default. If selected, it will install unmodified copies of /usr/bin/perl5.8.1 and related support files in /System/Library/Perl/5.8.1.

The 5.8.6 (Tiger) and 5.8.8 (Leopard) packages will install /usr/bin/perl5.8.6 and /usr/bin/perl5.8.8, respectively, and related support files under /System/Library/Perl/. These Perls have had their Config.pm modules patched, so that they will use specific versions of GCC and Xcode SDKs when building XS modules - GCC 4.0 & the 10.4u SDK for Tiger, and GCC 4.2 & the 10.5 SDK for Leopard. This allows them to be used to build XS modules on Snow Leopard for deployment on earlier Mac OS X versions.

The 5.8.9 (Snow Leopard) package installs an unmodified copy of /usr/bin/perl5.8.9 and related support files under /System/Library/Perl/5.8.9. Unlike the earlier 1.1.0 release of this package, which was built on Leopard and had compatibility problems as a result, this is the real thing, copied directly from an actual Snow Leopard install.