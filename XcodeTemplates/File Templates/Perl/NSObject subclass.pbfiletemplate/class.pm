#!/usr/bin/perl

#
#  «FILENAME»
#  «PROJECTNAME»
#
#  Created by «FULLUSERNAME» on «DATE».
#  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.
#

package «FILEBASENAMEASIDENTIFIER»;
use CamelBones qw(:All);
use strict;
use warnings;

class «FILEBASENAMEASIDENTIFIER» {
    'super' => 'NSObject',
    'properties' => [
                    ],
};

sub init : Selector(init) ReturnType(@) {
    my ($self) = @_;
    $self = $self->SUPER::init();

    if ($self) {
        # Add code here to perform any custom initialization for this object
    }
    
    return $self;
}

# Happy Perl
1;