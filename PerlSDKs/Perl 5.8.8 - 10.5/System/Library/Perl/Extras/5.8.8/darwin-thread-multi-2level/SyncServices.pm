# (C) Copyright 2006 Apple Computer, Inc. All rights reserved.
# (C) Copyright 2007 Apple Inc. All rights reserved.
# 
# IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
# (Apple) in consideration of your agreement to the following terms, and your
# use, installation, modification or redistribution of this Apple software
# constitutes acceptance of these terms.  If you do not agree with these terms,
# please do not use, install, modify or redistribute this Apple software.
# 
# In consideration of your agreement to abide by the following terms, and subject
# to these terms, Apple grants you a personal, non-exclusive license, under
# Apples copyrights in this original Apple software (the Apple Software), to use,
# reproduce, modify and redistribute the Apple Software, with or without
# modifications, in source and/or binary forms; provided that if you redistribute
# the Apple Software in its entirety and without modifications, you must retain
# this notice and the following text and disclaimers in all such redistributions
# of the Apple Software.  Neither the name, trademarks, service marks or logos of
# Apple Computer, Inc. may be used to endorse or promote products derived from
# the Apple Software without specific prior written permission from Apple.
# Except as expressly stated in this notice, no other rights or licenses, express
# or implied, are granted by Apple herein, including but not limited to any
# patent rights that may be infringed by your derivative works or by other works
# in which the Apple Software may be incorporated.
# 
# The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
# WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
# WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
# COMBINATION WITH YOUR PRODUCTS. 
# 
# IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
# DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
# CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
# APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package SyncServices;

@ISA = qw(Exporter);
@EXPORT = qw(NSArrayOfNSStringsFromListOfPerlStrings listOfPerlStringsFromNSArrayOfNSStrings objectRefFromPerlRef perlRefFromObjectRef);

use PerlObjCBridge;
use Foundation;
use POSIX(strtod);

# These are generally useful routines, so I am exporting them from
# SyncServices. The other exports needed to override to get the behavior I
# wanted. See comments below if you are interested.
*NSArrayOfNSStringsFromListOfPerlStrings = \&Foundation::NSArrayOfNSStringsFromListOfPerlStrings;
*listOfPerlStringsFromNSArrayOfNSStrings = \&Foundation::listOfPerlStringsFromNSArrayOfNSStrings;

my $FrameworkLoaded = 0;

BEGIN {
  my $path = NSString->stringWithCString_('/System/Library/Frameworks/SyncServices.framework');
  my $framework = NSBundle->alloc->init->initWithPath_($path);
  $framework->load();

  if ($framework->isLoaded()) {
	$FrameworkLoaded = 1;
  }
  else {
	print STDERR "Failed to load SyncServices framework at $path\n";
  }
}

# I overrride bytes for NSConcrete data since for Leopard at least, the bytes
# method signature is now a void * which the bridge then returns as an SVInt. I
# do not believe there is a way to get Perl to recognize this int as a pointer
# to memory, even with pack/unpack shenanigans. Needless to say, this is a
# brittle implementation. Better would be to provide a category method on NSData
# and NSMutableData in the Foundation.xs file for bytes that had a (unsigned
# char *)return value and the provide a wrapper method in the Foundation.pm for bytes
# that called out to this method.

package NSConcreteData;

sub bytes {
  my ($self) = @_;
  my $desc = $self->description()->UTF8String();
  my $desclen = 2 * $self->length();
  $desc =~ s/^<//;
  $desc =~ s/>$//;
  $desc =~ s/ //g;
  return pack("H$desclen",$desc);
}

package SyncServices;

sub isANumber {
  my ($str) = @_;
  $str =~ s/^\s+//;
  $str =~ s/\s+$//;
  $! = 0;
  my ($num,$unparsed) = strtod($str);
  if(($str eq '') || ($unparsed != 0) || $!) {
	return undef;
  }
  else {
	return $num;
  }
}

# Unlike the default implementation we will return the $perlRef if we are of
# PerlObjCBridge. We will also return a reference to an NSNumber if the Perl
# reference or object is a number.

sub objectRefFromPerlRef
{
  my($perlRef) = @_;

  return undef unless defined($perlRef);

  # switch based on the type of the referent
  my($referent) = ref($perlRef);
  if (not $referent) {			# argument is not a reference so return a string.
	my $num;
	if(($num = isANumber($perlRef))) {
	  return NSNumber->numberWithDouble_($num);
	}
	else {
	  return NSString->stringWithUTF8String_("$perlRef");
	}
  } elsif ($referent eq 'SCALAR') {	# reference to scalar value
	my $num;
	if(($num = isANumber($$perlRef))) {
	  return NSNumber->numberWithDouble_($num);
	}
	else {
	  return NSString->stringWithUTF8String_("$$perlRef");
	}
  } elsif ($referent eq 'ARRAY') { # reference to list
	my($nsarray) = NSMutableArray->arrayWithCapacity_(int(@$perlRef));
	return undef unless $$nsarray;
	foreach $item ( @$perlRef ) {
	  my($nsobject) = &objectRefFromPerlRef($item);
	  return undef unless $$nsobject;
	  $nsarray->addObject_($nsobject);
	}
	return $nsarray;
  } elsif ($referent eq 'HASH') { # reference to hash
	my(@keys) = keys(%$perlRef);
	my($nsdict) = NSMutableDictionary->dictionaryWithCapacity_(int(@keys));
	return undef unless $$nsdict;
	foreach $key ( @keys ) {
	  my($keyObject) = NSString->stringWithUTF8String_("$key");
	  return undef unless $$keyObject;
	  my($valueObject) = &objectRefFromPerlRef($perlRef->{$key});
	  return undef unless $$valueObject;
	  $nsdict->setObject_forKey_($valueObject, $keyObject);
	}
	return $nsdict;
  } elsif($perlRef->isa('PerlObjCBridge')) {
	return $perlRef;			# We already are an object reference so just return it.
  }
  else {
	return undef;
  }
}

my $nsstringClass = NSString->class();
my $nsnumberClass = NSNumber->class();
my $nsdataClass = NSData->class();
my $nsdateClass = NSDate->class();
my $nsarrayClass = NSArray->class();
my $nssetClass = NSSet->class();
my $nsdictionaryClass = NSDictionary->class();

# Unlike the default implementation we also handle NSSet. An NSSet will just be
# returned as a perl Array reference .We also will return containers of
# PerlObjCBridge references for NSObjects in containers that cannot be
# reasonably converted to a Perl string. In the case of NSDictionaries we
# require that the key be convertable to a Perl string.
sub perlRefFromObjectRef
{
  my($nsobject,$nsobjectRefsAreOk) = @_;

  return undef unless $$nsobject;

  # switch based on kind of object
  if ($nsobject->isKindOfClass_($nsstringClass)) { # NSString
	return $nsobject->UTF8String();
  } elsif ($nsobject->isKindOfClass_($nsnumberClass)) {	# NSNumber
	return $nsobject->stringValue()->UTF8String();
  } elsif ($nsobject->isKindOfClass_($nsdataClass)) { # NSData
	return $nsobject->bytes();
  } elsif ($nsobject->isKindOfClass_($nsdateClass)) { # NSDate
	return $nsobject->description()->UTF8String();
  } elsif (($nsobject->isKindOfClass_($nsarrayClass)) ||
		   ($nsobject->isKindOfClass_($nssetClass))) { # NSArray or NSSet
	my($enumerator) = $nsobject->objectEnumerator();
	return undef unless $$enumerator;
	my(@array);
	while ($nsobject2 = $enumerator->nextObject() and $$nsobject2) {
	  my($perlRef) = &perlRefFromObjectRef($nsobject2, 1); # A perl array of NSObject references is ok.
	  return undef unless defined($perlRef);
	  push(@array, $perlRef);
	}
	return \@array;
  } elsif ($nsobject->isKindOfClass_($nsdictionaryClass)) {	# NSDictionary
	my($enumerator) = $nsobject->keyEnumerator();
	return undef unless $$enumerator;
	my(%hash);
	while ($keyObject = $enumerator->nextObject() and $$keyObject) {
	  my($keyRef) = &perlRefFromObjectRef($keyObject,0); 
	  return undef unless defined($keyRef) and (not ref($keyRef));
	  my($valueObject) = $nsobject->objectForKey_($keyObject);
	  return undef unless $$valueObject;
	  my($valueRef) = &perlRefFromObjectRef($valueObject,1); # A perl hash to NSObject references is ok.
	  return undef unless defined($valueRef);
	  $hash{$keyRef} = $valueRef;
	}
	return \%hash;
  } elsif ($nsobjectRefsAreOk) {
	  return $nsobject;
	}
  else {
	return undef;
  }
}

package ISyncManager;
@ISA = (PerlObjCBridge);
@EXPORT = qw( );

package ISyncClient;
@ISA = (PerlObjCBridge);
@EXPORT = qw( );

package ISyncChange;
@ISA = (PerlObjCBridge);
@EXPORT = qw( );

package ISyncRecordSnapshot;
@ISA = (PerlObjCBridge);
@EXPORT = qw( );

package ISyncSession;
@ISA = (PerlObjCBridge);
@EXPORT = qw( );

package ISyncSessionDriver;
@ISA = (PerlObjCBridge);
@EXPORT = qw( );

1;
