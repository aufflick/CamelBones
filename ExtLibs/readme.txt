Expat and PostgreSQL compiled with:

CFLAGS='-isysroot/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc -mmacosx-version-min=10.4'
LDFLAGS='-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc -mmacosx-version-min=10.4'
CC='/usr/bin/gcc-4.0'

MySQL compiled with:

CFLAGS=-g -Os -fno-omit-frame-pointer -isysroot/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc -mmacosx-version-min=10.4
CXXFLAGS=-g -Os -fno-omit-frame-pointer -fno-exceptions -fno-rtti -isysroot/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc -mmacosx-version-min=10.4
LDFLAGS=-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc -mmacosx-version-min=10.4 -lz
CC=/usr/bin/gcc-4.0
CXX=/usr/bin/g++-4.0

./configure --prefix=/Users/sherm/Projects/CamelBones/ExtLibs --disable-shared --disable-dependency-tracking --enable-thread-safe-client --enable-largefile --with-gnu-ld --without-server

All directories except lib/ and include/ deleted after install
