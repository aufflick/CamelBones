#!/bin/sh

# Clean up first
sudo rm -rf /Developer/CamelBones/Frameworks
sudo rm -rf /Developer/CamelBones/Bundle-Frameworks
sudo rm -rf /Library/Frameworks/CamelBones.framework
sudo rm -rf /Developer/CamelBones/Modules

# Build newest platforms first, older ones last, to leave the
# most compatible stub when everything is finished.
sudo gcc_select 4.0
export -n MACOSX_DEPLOYMENT_TARGET

# Build Tiger/5.8.6 shared/universal
./configure --with-perl=/usr/bin/perl5.8.6 --with-sdk=/Developer/SDKs/MacOSX10.4u.sdk --enable-universal --enable-par --enable-kits
make
make test

# Keep the i386 binary to lipo it back into the stub later
lipo -extract i386 CamelBones.framework/CamelBones -output _stub.shared.i386
sudo make install
make cpan_clean
rm -rf CamelBones.framework

# Build Tiger/5.8.6 embedded
./configure --with-perl=/usr/bin/perl5.8.6 --with-sdk=/Developer/SDKs/MacOSX10.4u.sdk --enable-universal --enable-embedded --enable-par
make
make test

# Keep the i386 binary to lipo it back into the stub later
lipo -extract i386 CamelBones.framework/CamelBones -output _stub.embedded.i386
sudo make install

# Make a copy of the embedded Tiger framework, and adjust its install
# path to make it the bundled framework
sudo mkdir /Developer/CamelBones/Bundle-Frameworks
sudo cp -R /Developer/CamelBones/Frameworks/CamelBones.framework /Developer/CamelBones/Bundle-Frameworks
sudo install_name_tool -id '@loader_path/../Frameworks/CamelBones.framework/CamelBones' /Developer/CamelBones/Bundle-Frameworks/CamelBones.framework/CamelBones

make realclean

export MACOSX_DEPLOYMENT_TARGET=10.3

# Build Panther/5.8.1 shared
./configure --with-perl=/usr/bin/perl5.8.1 --with-sdk=/Developer/SDKs/MacOSX10.3.9.sdk --enable-par --enable-kits
make
make test
sudo make install
make cpan_clean
rm -rf CamelBones.framework

# Build Panther/5.8.1 embedded
./configure --with-perl=/usr/bin/perl5.8.1 --with-sdk=/Developer/SDKs/MacOSX10.3.9.sdk --enable-embedded --enable-par
make
make test
sudo make install
make realclean

# Jaguar has left the building

# Lipo the i386 binary back into the stub
mv CamelBones.framework/CamelBones _stub.embedded.ppc
lipo -create _stub.embedded.i386 _stub.embedded.ppc -output CamelBones.framework/CamelBones
rm _stub.embedded.i386 _stub.embedded.ppc
sudo make install
make realclean
