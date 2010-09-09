# (C) Copyright 2002-2008 Apple Computer, Inc. All rights reserved.
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


package PerlObjCBridge;
use strict;
use warnings;

use AutoLoader;
use DynaLoader;
use Exporter;
use Time::HiRes qw( gettimeofday );

our @ISA = qw( Exporter DynaLoader );
our @EXPORT = qw( );
our $VERSION = '2.0';

bootstrap PerlObjCBridge $VERSION;

# global variables
our $TRACE           = 0;
our $dieOnErrors     = 1;
our $dieOnExceptions = 1;
our $exceptionHandler;

sub TRACE {
    return unless $TRACE;
    my ($sec, $min, $hour, $day, $mon, $year) = localtime( time );
    my $header = sprintf( '%4d-%0.2d-%2d %2d:%2d:%2d.%0.6d PerlObjCBridge[%d] TRACE: ', $year+1900, $mon+1, $day, $hour, $min, $sec, (gettimeofday())[1], $$ );
    print STDERR $header, @_, "\n";
}

# Turn on/off bridge debug tracing (off by default)
sub setTracing {
    shift @_ if $_[0] eq 'PerlObjCBridge';
    $TRACE = @_ ? shift @_ : 1;
    PerlObjCBridge::setBridgeTracing( $TRACE );
}

sub tracingIsEnabled {
    return $TRACE ? 1 : 0;
}

# By default, failures to send Objective-C messages are fatal.
# This procedure can be used to control that behavior.
sub setDieOnErrors {
    $dieOnErrors = @_ ? shift @_ : 1;
}

# By default, exceptions raised during Objective-C messages are fatal.
# This procedure can be used to control that behavior.
sub setDieOnExceptions {
    $dieOnExceptions = @_ ? shift @_ : 1;
}

# This is the default Perl exception handler for NSExceptions.
# It prints the info contained in the Objective-C NSException object
# and then dies (depending on $dieOnExceptions).
sub defaultNSExceptionHandler {
    my ( $selector, $targetClass, $name, $reason, $userInfo ) = @_;
    my ( $file, $line ) = (caller(1))[1,2];
    
    print STDERR "PerlObjCBridge: NSException raised while sending $selector to $targetClass object\n";
    print STDERR "    name:     \"$name\"\n";
    print STDERR "    reason:   \"$reason\"\n";
    print STDERR "    userInfo: \"$userInfo\"\n";
    print STDERR "    location: \"$file line $line\"\n";
    if ( $dieOnExceptions ) {
        die "**** PerlObjCBridge: dying due to NSException\n";
    } else {
        printf STDERR "**** PerlObjCBridge: current method returns undef\n";
        return;
    }
}

$exceptionHandler = \&defaultNSExceptionHandler;

sub setNSExceptionHandler {
    $exceptionHandler = shift @_;
}

sub getNSExceptionHandler {
    return $exceptionHandler;
}

#
# PerlObjCBridge uses an AUTOLOAD method as its main dispatch function
# for sending messages to the Objctive-C runtime (and receiving the results).
#
# The first argument to AUTOLOAD is $self (a Perl class or reference).
# If $self is a Perl class then the message will be forwarded to the
# corresponding Objective-C class (as a class method). Otherwise, if
# $self is a Perl reference then the message will be forwarded to the
# associated Objective-C object.
#
# The remaining arguments are passed as parameters to the Objective-C method.
# 
# There exists a magic package variable $AUTOLOAD that defines the
# method name (ick!).
#
our $AUTOLOAD;
sub AUTOLOAD {
    
    $TRACE and do {
        TRACE( "--------------------------------------" );
        TRACE( "arguments to PerlObjCBridge::AUTOLOAD:" );
        foreach my $i ( 0 .. $#_ ) {
            TRACE( "$i\t", defined( $_[$i] ) ? $_[$i] : '<UNDEF>' );
        }
    };

    ##
    ## The following code processes $self, which is either
    ## a blessed Perl reference or a (possibly qualified) Perl class name
    ##

    # get $self as first argument
    my $self = shift @_;
    die '**** ERROR **** PerlObjCBridge::AUTOLOAD: $self is undefined'
        unless $self;

    # figure out whether this is an instance message or a class message,
    # based on whether $self is a reference or a class name, respectively.
    my $self_class_name;
    my $is_instance_message;
    if ( ref( $self ) ) {                   # it's a reference to an object
        $self_class_name = ref( $self );
        $is_instance_message = 1;
    } else {                                # it's a class name
        $self_class_name = $self;
        $is_instance_message = 0;
    }
    $TRACE and TRACE( '$self_class_name is ', $self_class_name );
    $TRACE and TRACE( '$is_instance_message is ', $is_instance_message );
    
    ##
    ## The following code extracts the method name from $AUTOLOAD
    ##

    # the method name being invoked is found in $AUTOLOAD
    die '**** ERROR **** PerlObjCBridge::AUTOLOAD: $AUTOLOAD is undefined or null'
        unless $AUTOLOAD;
    $TRACE and TRACE( '$AUTOLOAD is ', $AUTOLOAD );

    # get the class and method name from $AUTOLOAD
    my ( $autoload_class_name, $autoload_method_name ) = $AUTOLOAD =~ m{^(.*)::(.*)$};
    die "**** ERROR **** PerlObjCBridge::AUTOLOAD: invalid \$AUTOLOAD value $AUTOLOAD (no unqualified method name)"
        unless $autoload_method_name; 
    die "**** ERROR **** PerlObjCBridge::AUTOLOAD: invalid \$AUTOLOAD value $AUTOLOAD (no class name)"
        unless $autoload_class_name; 
    $TRACE and TRACE( '$autoload_method_name is ', $autoload_method_name );
    $TRACE and TRACE( '$autoload_class_name is ',  $autoload_class_name );

    # always ignore perl's DESTROY messages.
    return if $autoload_method_name eq 'DESTROY';

    # sanity check class name from $self against class name from $AUTOLOAD
    die "**** ERROR **** PerlObjCBridge::AUTOLOAD: \$self class $self_class_name and \$AUTOLOAD class $autoload_class_name do not match"
        unless $self_class_name eq $autoload_class_name; 
    
    # get the unqualified class name from the qualified class name
    ( my $unqualified_class_name = $self_class_name ) =~ s|.*::||;
    die "**** ERROR **** PerlObjCBridge::AUTOLOAD: invalid \$self_class_name $self_class_name"
        unless $unqualified_class_name; 
    $TRACE and TRACE( '$unqualified_class_name is ', $unqualified_class_name );
        
    ##
    ## The following code turns the Perl method name into an Objective-C signature
    ## and sends the message to the Objective-C runtime.
    ##

    # Objective-C'ify the method name
    ## first convert all underscores to colons
    ( my $objc_selector = $autoload_method_name ) =~ tr|_|:|;
    ## then convert back for methods that have leading underscores
    if ( $autoload_method_name =~ m{^(_+)} ) {
        my $prefix = $1;
        $objc_selector =~ m{^:+(.*)$};                 # convert leading colons back to underscores
        $objc_selector = $prefix . $1;
    }
    $TRACE and TRACE( '$objc_selector is ', $objc_selector );

    # send the message to the Objective-C runtime via the dispatch function in PerlObjCBridge.xs
    $TRACE and TRACE( '>>> sending message [', $unqualified_class_name, ' ', $objc_selector, ']' );
    my ( $returnStatus, $returnValue, $exceptionReason, $exceptionInfo );
    {
        no warnings;                # "use warnings" gripes if any arguments are undef or non-numeric
        ( $returnStatus, $returnValue, $exceptionReason, $exceptionInfo ) = PerlObjCBridge::sendObjcMessage(
            $is_instance_message,                       # flag indicating whether this message is sent to class or to object
            ( $is_instance_message ? $$self : 0 ),      # the Objective-C id, if this is an instance message
            $unqualified_class_name,                    # the Objective-C class name
            $objc_selector,                             # the Objective-C message selector
            @_                                          # the message arguments
        );
    }
    
    ##
    ## The following code processes the results from the Objective-C message
    ##

    # check the return status value
    if ( $returnStatus == 0 ) {               # message sent OK
        $TRACE and TRACE( "<<< success sending message [$unqualified_class_name $objc_selector]: \$returnStatus is $returnStatus" );
        if ( ref( $returnValue ) ) {
            $TRACE and TRACE( sprintf( "\$returnValue for %s is 0x%x, \$\$returnValue is 0x%x, return type is %s", $objc_selector, $returnValue, $$returnValue, ref( $returnValue ) ) );
        } else {
            $TRACE and TRACE( sprintf( "\$returnValue for %s is %s", $objc_selector, defined( $returnValue) ? $returnValue : '<UNDEF>' ) );
        }
        return $returnValue;
    }
    elsif ( $returnStatus == 1 ) {            # there was an error attempting to send the message
        $TRACE and TRACE( "<<< error sending message [$unqualified_class_name $objc_selector]: \$returnStatus is $returnStatus" );
        if ( $dieOnErrors ) {
            die "**** ERROR **** PerlObjCBridge: error [$returnStatus] sending message [$unqualified_class_name $objc_selector]";
        } else {
            warn "**** WARNING **** PerlObjCBridge: error [$returnStatus] sending message [$unqualified_class_name $objc_selector]";
            return;
        }
    }
    elsif ( $returnStatus == 2 ) {            # message sent, exception raised
        $TRACE and TRACE( "<<< exception sending message [$unqualified_class_name $objc_selector]: \$returnStatus is $returnStatus" );
        if ( $exceptionHandler ) {
            return &$exceptionHandler( $objc_selector, $unqualified_class_name, $returnValue, $exceptionReason, $exceptionInfo );
        } else {
            $dieOnExceptions = 1;
            defaultNSExceptionHandler( $objc_selector, $unqualified_class_name, $returnValue, $exceptionReason, $exceptionInfo );
        }
    }
    else {
        die "**** ERROR **** PerlObjCBridge::AUTOLOAD: unknown return status [$returnStatus] sending message [$unqualified_class_name $objc_selector]";
    }
}


# The DESTROY method is invoked by Perl when a Perl object becomes unreferenced.
# If the Perl object wraps an Objective-C id, then a DESTROY of the Perl object
# must result in releasing the Objective-C object. Similarly for Perl objects that
# wrap C structs.
#
# The first argument to DESTROY is always $self (the Perl object to be destroyed).
sub DESTROY {
    my $self = shift @_;
    
    $TRACE and TRACE( sprintf( "PerlObjCBridge::DESTROY called for 0x%lx", $self ) );

    # return unless $self is a reference
    unless ( ref( $self ) ) {
        return;
    }
    
    # check for release of null object (Objective-C id is "nil" or pointer to C struct is NULL)
    unless ( $$self ) {
        $TRACE and TRACE( sprintf( "PerlObjCBridge::DESTROY called for null pointer or id of class %s", ref( $self ) ) );
        return;
    }
    
    # decide whether Perl object wraps an Objective-C object or a C struct
    if ( ref( $self ) eq 'PerlObjCBridge' ) {
        $TRACE and TRACE( sprintf( "PerlObjCBridge::DESTROY called for struct 0x%lx", $$self ) );
        PerlObjCBridge::releaseStruct( $$self );
    } else {
        $TRACE and TRACE( sprintf( "PerlObjCBridge::DESTROY called for \$self == 0x%x, \$\$self ==  0x%x, of class %s", $self, $$self, ref( $self ) ) );
        PerlObjCBridge::releaseObjectiveCObject( $$self );
    }
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

PerlObjCBridge.pm - Bridges Perl and Objective-C runtimes

=head1 SYNOPSIS

    use Foundation;
    
    $s1 = NSString->stringWithCString_("Hello ");
    $s2 = NSString->alloc()->initWithCString_("World");
    $s3 = $s1->stringByAppendingString_($s2);
    printf "%s\n", $s3->cString();
  
=head1 SUMMARY

The PerlObjCBridge module supports creating and messaging Objective-C objects from Perl programs, allowing Cocoa objects in Apple Computer's Mac OS X to be directly manipulated from Perl. In addition, Perl objects can be messaged from Objective-C, making it possible for Perl objects to function as Cocoa delegates and as targets of notifications and other Cocoa call-back messages. Perl programs can take advantage of Cocoa's Distributed Objects mechanism to support messaging between Perl objects and Objective-C objects (or other Perl objects) in different address spaces, possibly on different machines.

=head1 LIMITATION

This version of PerlObjCBridge does not directly support writing GUI Cocoa applications in Perl. Consult http://www.sourceforge.net/projects/camelbones for a freeware package that supports GUI Perl/Cocoa apps.

=head1 DESCRIPTION

Using PerlObjCBridge, Perl programs can reference Objective-C objects in a manner similar to references to native Perl objects. The Objective-C objects must inherit from the NSObject root class in the Mac OS X Foundation framework (which is true for Cocoa objects). In Objective-C an object is accessed via an object identifier that is implemented as a pointer to a structure containing the object's instance data. PerlObjCBridge represents an Objective-C object as a Perl reference to a scalar value that contains the Objective-C ID. For example, if an Objective-C object has an ID with value 0x12345678, then PerlObjCBridge represents that object as a reference to a scalar with value 0x12345678. The Perl reference is "blessed" into a Perl class that has the same name as the Objective-C class. The Perl inheritance mechanism is then used to route any messages sent to the object from Perl through the PerlObjCBridge extension module and ultimately to the Objective-C object. The return values of the Objective-C messages are similarly routed back through the bridge where they are converted into Perl return values.

It is also possible to use Perl objects in places where Cocoa methods normally take Objective-C arguments. For example, one can register Perl objects to receive NSNotifications, in which case the perl objects provide the notification handling methods that are asynchronously messaged by NSNotificationCenter when interesting events occur. As another example, a Perl object can be registered as a server object via NSConnection, after which Objective-C or Perl objects in other address spaces can send messages to the server object via the Distributed Objects mechanism. In these examples an Objective-C proxy object is created by PerlObjCBridge that gets passed to Objective-C methods, and that forwards messages from Objective-C to the Perl object.

=head1 MESSAGING

Ordinary Perl "object->method(argument-list)" syntax is used to send messages to Objective-C objects. The ':' character that delimits arguments in Objective-C is illegal in Perl method names, so underscores are used instead. An method that is invoked in Objective-C as:

    [anObject arg1:x arg2:y];
    
can be invoked from Perl using something like:

    $anObject->arg1_arg2_($x, $y);

Contrast the following Objective-C code fragment with its Perl analogue in the synopsis at the top of this man page:

    #import <Foundation/Foundation.h>

    NSString *s1 = [NSString stringWithCString:"Hello "];
    NSString *s2 = [[NSString alloc] initWithCString:"World"];
    NSString *s3 = [s1 stringByAppendingString:s2];
    printf("%s\n", [s3 cString]);

To send a message to an Objective-C class, one uses the syntactic form ClassName->method(...args...). For example, one can send the "defaultManager" message to the NSFileManager class as follows:

    $defMgr = NSFileManager->defaultManager();
    
An important special case of a class method is a "factory" method that constructs a new instance of a class:

    $array = NSMutableArray->array();
    
    $string = NSString->stringWithCString_("Hi there");
    
The NSString factory method illustrates how PerlObjCBridge passes Perl strings to Objective-C as char *'s.

To send a message to an Objective-C object, one uses the syntactic form $object->method(...args...). If $array is a reference to an NSMutableArray then one can add the NSString referenced by $string by sending $array the "addObject:" message:

    $array->addObject_($string);
    
Message sends can be chained from left to right:

    $hostName = NSProcessInfo->processInfo()->hostName();
    
In the above example, the object returned by NSProcessInfo->processInfo() is in turn sent the hostName message.

=head1 USING COCOA FRAMEWORKS

PerlObjCBridge automatically generates a bridge module for the Foundation framework that is included with the Cocoa environment in Mac OS X. This bridge module is created when PerlObjCBridge is built. The bridge module for a framework causes that framework to be dynamically loaded into the Perl program's address space. In addition Perl packages are created for each of the Objective-C classes in the framework so that the Objective-C classes exist in the Perl name space.

To access a framework from Perl "use" its bridge module. For example, to access Foundation objects do:

    use Foundation;
    
=head1 DISTRIBUTED MESSAGING

Perl objects can send messages to other objects (Perl or Cocoa) in different address spaces by using Cocoa's Distributed Objects (DO) mechanism. This makes it easy to create distributed systems (such as client/server systems) that mix Perl and Cocoa programs. It also makes it easy to create a pure Perl distributed system, where Perl objects in different address spaces communicate via Cocoa DO.

Here is a complete example of a distributed client/server system, where the client and server objects are written in Perl but communicate by means of DO. The system consists of a Perl client program, a Perl server program, and a Perl XSUB module that provides the glue between the Perl programs and DO. The XSUB module is initially created by running the following  command:

    h2xs -A -n AddSystem
    
An AddSystem directory is created with these files:

    ppport.h
    lib/AddSystem.pm
    AddSystem.xs
    Makefile.PL
    README
    t/AddSystem.t    
    Changes
    MANIFEST
    
Edit the Makefile.PL DEFINE entry to add the -ObjC flag:

    'DEFINE'		=> '-ObjC', # e.g., '-DHAVE_SOMETHING'
    
Modify the contents of AddSystem.pm to contain:

    package AddSystem;

    @ISA = qw(Exporter DynaLoader);
    @EXPORT = qw( );
    $VERSION = '1.0';
    bootstrap AddSystem $VERSION;

    use Foundation;

    1;

and modify AddSystem.xs to have the contents:

    #include <mach-o/dyld.h>
    #include "EXTERN.h"
    #include "perl.h"
    #include "XSUB.h"
    #ifdef Move
    #undef Move
    #endif Move
    #ifdef DEBUG
    #undef DEBUG
    #endif DEBUG
    #ifdef I_POLL
    #undef I_POLL
    #endif I_POLL
    #import <Foundation/Foundation.h>

    @interface AddClient : NSObject
    @end

    @implementation AddClient
    - (int)firstNumber { return 0; }
    - (int)secondNumber { return 0; }
    @end

    @interface AddServer: NSObject
    @end

    @implementation AddServer
    - (int)addNumbersForClient:(NSObject *)client { return 0; }
    @end

    MODULE = AddSystem		PACKAGE = AddSystem		

AddSystem.xs defines "dummy" AddClient and AddServer Objective-C classes that implement the methods that the Perl client and server will provide. These dummy Objective-C classes are needed in this case because there would otherwise not be enough information for the DO runtime system to determine the numbers, types, and sizes of the method arguments and return values. These dummy Objective-C implementations are usually only needed when DO is being used and the Perl program does not link against any libraries that contain objects that already implement the methods. The actual method bodies are irrelevant and can be trivially defined to return 0 or NULL. In the case of methods that return void, the dummy methods can have empty bodies.

After modifying Makefile.PL, AddSystem.pm, and AddSystem.xs, execute the following commands (as root or as an admin user):

    perl Makefile.PL
    make install

Now add two Perl programs to the AddSystem directory. The first program is addServer:

    #!/usr/bin/perl

    use AddSystem;

    package AddServer;
    @ISA = qw(PerlObjCBridge);
    @EXPORT = qw( );

    PerlObjCBridge::preloadSelectors('AddClient');

    sub new
    {
        my $class = shift;
        my $self = {};
        bless $self, $class;
        return $self;
    }

    sub addNumbersForClient_
    {
        my($self, $client) = @_;
        my $first = $client->firstNumber();
        my $second = $client->secondNumber();
        return int($first + $second);
    }

    $server = new AddServer;
    $connection = NSConnection->defaultConnection();
    $connection->setRootObject_($server);
    $connection->registerName_(NSString->stringWithCString_("AddServer"));

    NSRunLoop->currentRunLoop()->run();

Make sure that the line "#!/usr/bin/perl" does not contain leading whitespace.

The line:

    use AddSystem;

causes addServer to load the AddSystem XSUB module, which in turn loads the dummy AddClient and AddServer Objective-C classes, thus making them available to the DO runtime system. The lines:

    package AddServer;
    @ISA = qw(PerlObjCBridge);
    @EXPORT = qw( );

cause the AddServer package to inherit from PerlObjCBridge. As a consequence, messages to and from AddServer objects will be routed through PerlObjCBridge.

The line:

    PerlObjCBridge::preloadSelectors('AddClient');

instructs PerlObjCBridge to pre-cache all method selectors for the Objective-C class AddClient. By doing this, PerlObjCBridge is "primed" with the information needed to send messages to objects of class AddClient. 
 
After a standard "new" constructor method, there is a addNumbersForClient_ method that provides the service vended by the AddServer class. The method name "addNumbersForClient_" corresponds to the Objective-C selector "addNumbersForClient:", which has a dummy implementation in AddSystem.xs. In addition to the standard $self argument, addNumbersForClient_ takes a second argument $client which is a reference to the invoking client object. The client object is then sent the messages "firstNumber" and "secondNumber", each of which returns an integer. The server adds the two numbers and returns the result.

The lines:

    $server = new AddServer;
    $connection = NSConnection->defaultConnection();
    $connection->setRootObject_($server);
    $connection->registerName_(NSString->stringWithCString_("AddServer"));

create a new AddServer object and set it as the root object of a DO connection, registered with the name "AddServer". Clients can then look up the name "AddServer" to connect to this object.

The final line:

    NSRunLoop->currentRunLoop()->run();

puts addServer into a event loop, waiting for incoming connections from clients.

The second program, addClient, consists of:

    #!/usr/bin/perl

    use AddSystem;

    package AddClient;
    @ISA = qw(PerlObjCBridge);
    @EXPORT = qw( );

    PerlObjCBridge::preloadSelectors('AddServer');

    sub new
    {
        my $class = shift;
        my $self = {};
        bless $self, $class;
        $self{'firstNumber'} = shift;
        $self{'secondNumber'} = shift;
        return $self;
    }

    sub firstNumber
    {
        my($self) = @_;
        return $self{'firstNumber'};
    }

    sub secondNumber
    {
        my($self) = @_;
        return $self{'secondNumber'};
    }

    die "usage: perlClient <firstNumber> <secondNumber>\n" unless @ARGV == 2;

    # create client
    $client = new AddClient (@ARGV);
    
    # create connection to server
    $name = NSString->stringWithCString_("AddServer");
    $server = NSConnection->rootProxyForConnectionWithRegisteredName_host_($name, 0);
    if (!$server or !$$server) {
        print "Can't get server\n";
        exit(1);
    }
    $server->retain();
    
    printf "%d\n", $server->addNumbersForClient_($client);

Make sure that the line "#!/usr/bin/perl" does not contain leading whitespace.

The AddClient methods "firstNumber" and "secondNumber" implement the call-back methods invoked by the AddServer. The lines:

    $name = NSString->stringWithCString_("AddServer");
    $server = NSConnection->rootProxyForConnectionWithRegisteredName_host_($name, 0);
    if (!$server or !$$server) {
        print "Can't get server\n";
        exit(1);
    }
    $server->retain();

results in $server being assigned a DO "proxy" object for the AddServer object in the addServer program. Any messages sent by the client will by forwarded by the DO proxy to the actual AddServer object in the addServer address space.

The final line:

    printf "%d\n", $server->addNumbersForClient_($client);

invokes the AddServer object with a reference to the client object. The control flow that results is:

    addClient sends "addNumbersForClient:" to addServer
    addServer sends "firstNumber" to addClient
    addClient returns first number
    addServer sends "secondNumber" to addClient
    addClient returns second number
    addServer returns sum of first and second number
    
To execute these programs, first make sure addServer and addClient are executable:

    chmod +x addServer addClient

Next run the server in one shell:

    addServer
    
then the client in another shell:

    addClient 1 2
    3
    
=head1 AUTOMATIC STRING CONVERSION

For convenience, PerlObjCBridge automatically converts Perl strings into NSString Objective-C objects when an NSObject is expected as the argument to an Objective-C method. For example, suppose an Objective-C dictionary is created:

    $dict = NSMutableDictionary->dictionary();
    
The dictionary method "setObject:forKey:" expects the key argument to be an NSString and the value argument to be any NSObject. The following automatically converts both "aKey" and "aValue" to NSStrings and then inserts the pair into the dictionary:

    $dict->setObject_forKey_("aValue", "aKey");
    
The value can be retrieved as follows, where "aKey" is again automatically converted to an NSString:

    $value = $dict->objectForKey_("aKey");
    printf "value is %s\n", $value->cString();

Note that the return value assigned to $value is a reference to an NSString and is not automatically converted to a Perl string. The automatic conversions occur only from Perl strings to NSStrings for Objective-C method arguments. NSStrings return values are not automatically converted to Perl strings.

Automatic conversion also occurs when a Perl string is passed as an argument to a method that expects an Objective-C selector. For example, the "performSelector:" message can be sent to any NSObject. The argument to the "performSelector:" message must be an Objective-C selector. In Objective-C, one can copy an existing NSString "origString" by asking it to perform the "copy" selector:

    copy = [origString performSelector:@selector(copy)];
    
This is equivalent to:

    copy = [origString copy];
    
In Perl the selector form can be executed as:

    $copy = $origString->performSelector_("copy");
    
In this case the Perl string "copy" is automatically converted to an Objective-C selector.

=head1 NIL ARGUMENTS AND RETURN VALUES

It is sometimes necessary to pass the Objective-C object ID "nil" (a null pointer) as an argument to an Objective-C method. Since PerlObjCBridge represents Objective-C ID's as Perl references, strictly speaking the Perl value 0 is not a legal representation for Objective-C's nil because it is a simple scalar, not a reference. However, for convenience, when an argument to an Objective-C method is expected to be an object ID and the value 0 is passed from Perl, PerlObjCBridge coerces the 0 value to a reference to a zero-valued scalar and the Objective-C method receives nil for that argument. In the following example, the Objective-c method "arg1:optionalArg:" would receive nil as its second argument.

    MyClass->arg1_optionalArg_($obj, 0);
    
The special value "undef" can also be used:

    MyClass->arg1_optionalArg_($obj, undef);
    
When an Objective-C method returns nil, the corresponding Perl return value is a reference to a zero-valued scalar. This return value can subsequently be passed as an argument to an Objective-C method. In the following example, if "aMethod" returns nil then "arg1:optionalArg:" would receive nil as its second argument:

    MyClass->arg1_optionalArg_($obj, YourClass->aMethod());

To determine whether an Objective-C method returned nil one should test both the Perl reference and its referent. The referent will be zero-valued when the Objective-C method returned nil, but it is also possible for the reference itself to be undefined (for example, when the method raised an NSException, as discussed below). The following example illustrates the use of an Objective-C NSEnumerator object to print the elements of an NSArray. In Objective-C, the enumerator returns nil after the last object in the array has been enumerated. In the Perl loop, both the reference $obj and the referent $$obj are tested in the loop condition. Under normal circumstances looping ends when $$obj becomes zero-valued, indicating the enumerator returned nil.

    $enumerator = $array->objectEnumerator();
    while ($obj = $enumerator->nextObject() and $$obj) {
        printf "%s\n", $obj->description()->cString();
    }

=head1 EXCEPTION HANDLING

NSExceptions that are raised as a result of messages sent by Perl programs to Objective-C objects are dealt with as follows. PerlObjCBridge has a built-in NSException handler that writes the message selector, the class of the target object, and the NSException name, reason, and userInfo to standard error. By default, the built-in NSException handler then dies with a message. The function PerlObjCBridge::setDieOnExceptions() can be used to control the latter behavior. Invoking setDieOnExceptions() with an argument of 0 will cause the built-in exception handler to issue a warning and return without dying, whereas a non-zero argument (or no argument) will cause the built-in exception handler to die. In the case where the built-in exception handler returns with a warning, the original message that caused the exception returns undef.

Alternatively, the Perl program can set its own exception handler by calling PerlObjCBridge::setNSExceptionHandler() with a single argument that must be a reference to a Perl function that acts as the exception handler. The Perl program can get a reference to the current exception handler by calling PerlObjCBridge::getNSExceptionHandler(). If a user-defined exception handler is set and an NSException is raised then the user-defined handler will be called with five string arguments: (1) the Objective-C selector for the message that induced the NSException, (2) the class name of the object to which the message was sent, and (3,4,5) the NSException name, reason, and userInfo (the latter represented as the string [userInfo description]). If the user-defined exception handler returns, then the original message returns undef. When a user-defined exception handler is set, it is up to the handler to decide whether the program exits or continues when NSExceptions are raised (i.e., when a user-defined exception handler is set the function setDieOnExceptions() has no effect).

The example below stores the original exception handler, sets a new exception handler, provokes an NSException by attempting to set a dictionary entry with a nil key and a nil value, and then restores the original exception handler.  

   sub myHandler
   {
       my($sel, $pkg, $name, $reason, $userInfo) = @_;
       print "NSException raised!\n";
       print "selector:  $selector\n";
       print "package:   $package\n";
       print "name:      $name\n";
       print "reason:    $reason\n";
       print "userInfo:  $userInfo\n";
   }

   $oldHandler = PerlObjCBridge::getNSExceptionHandler();
   PerlObjCBridge::setNSExceptionHandler(\&myHandler);
   $dict = NSMutableDictionary->dictionary();
   $dict->setObject_forKey_(0, 0);
   PerlObjCBridge::setNSExceptionHandler($oldHandler);

This results in myHandler printing the output:

   NSException raised!
   selector:     setObject:forKey:
   target class: NSCFDictionary 
   name:         NSInvalidArgumentException
   reason:       *** -[NSCFDictionary setObject:forKey:]: attempt to insert nil key
   userInfo:     

=head1 LARGE NUMERIC VALUES

PerlObjCBridge assumes no Perl support for 64-bit integers. When an Objective-C method has a 64-bit integer return type (i.e., long long or unsigned long long) and the result of invoking that method is a return value that is too large (i.e., >= 2^^31) or too small (<= -(2^^31)) to be represented in Perl as a signed integer then the value is returned as a Perl double. Similarly, when a parameter to an Objective-C method is a long long or unsigned long long then the type of the Perl argument value is examined. If the argument value is a Perl integer then its value is passed directly to the Objective-C method in long long or unsigned long long form (coercing in the unsigned case). Otherwise if the argument value is a Perl double then it is coerced to the appropriate long long or unsigned long long form before it is passed to the method.

Similar considerations apply to 32-bit unsigned longs and unsigned ints. When an Objective-C method has a 32-bit unsigned long or unsigned int return type and the result of invoking that method is a return value that is too large (>= 2^^31) to be represented in Perl as a signed integer then the value is returned as a Perl double. When a parameter to an Objective-C method is a 32-bit unsigned long or unsigned int then the Perl int or float argument is simply coerced to the unsigned long or int. This can of course have unpleasant consequences if the Perl argument is negative or larger than 2^^32.
 
=head1 CONTROL FUNCTIONS

Calling PerlObjCBridge::setTracing() with a non-zero argument (or no argument) will cause PerlObjCBridge to log diagnostic messages as it executes. Calling setTracing() with an argument of zero turns the diagnostics off.

Calling PerlObjCBridge::setDieOnErrors() with a non-zero argument (or no argument) will cause PerlObjCBridge to die with a warning message whenever there is an error during the sending of an Objective-C message (this is the default behavior). Calling setDieOnErrors() with an argument of zero allows the program to print a warning message but not die after such an error.

=head1 BUGS AND LIMITATIONS

PerlObjCBridge should take advantage of Perl support for 64-bit integers if available. Feel free to fix this.

When structs are passed by value, sometimes pointers embedded in the structs get mangled. It is better to pass structs by reference if they contain embedded pointers.

Varargs-style messaging is not supported. This is unfortunate, but it's due to the lack of varargs support in NSInvocation and NSMethodSignature. Fix that and it should be easy to support varargs messaging in PerlObjCBridge.

Access to functions, variables, and other non-object-oriented constructs exported by libraries containing Objective-C is not currently supported. It seems dubious that those things are exported as C-level constructs to begin with, when they could/should be Objective-C class methods. One possible workaround is to create an XSUB that provides Objective-C "covers" for these items. For example, if a library exports a variable:

    extern int GreatBigFoo;
    
then an XSUB with a cover might define:

    @interface Covers: NSObject
    + (int)GreatBigFoo;
    @end
    
    @implementation Covers
    + (int)GreatBigFoo
    {
        return GreatBigFoo;
    }
    @end
    
Then the value of the variable could be accessed in Perl:

    $gbf = Covers::GreatBigFoo();

=head1 SEE ALSO

perl(1).
Mac OS X: /Developer/Documentation/Cocoa/ObjectiveC
Mac OS X: /Developer/Documentation/Cocoa/Reference/Foundation

=cut
