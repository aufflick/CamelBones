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
    'super' => 'NSView',
    'properties' => [
                    ],
};

sub initWithFrame : Selector(initWithFrame:) ArgTypes({NSRect=ffff}) ReturnType(@) {
    my ($self, $frame) = @_;
    $self = $self->SUPER::initWithFrame($frame);

    if ($self) {
        # Add code here to perform any custom initialization for this object
    }

    return $self;
}

sub drawRect : Selector(drawRect:) ArgTypes({NSRect=ffff}) {
    my ($self, $rect) = @_;

    # Drawing code goes here

}

# Happy Perl
1;
