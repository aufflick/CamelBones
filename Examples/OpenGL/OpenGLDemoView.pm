#
#  OpenGLDemoView.pm
#  OpenGL
#
#  Created by Sherm Pendley on 4/27/07.
#  Copyright 2007 Sherm Pendley. All rights reserved.
#

package OpenGLDemoView;

use CamelBones qw(:All);

use OpenGL qw(:glfunctions :glconstants);

# use strict;
use warnings;

class OpenGLDemoView {
	'super' => 'NSOpenGLView',
	'properties' => [
	    'needInit',
	],
};

sub awakeFromNib : Selector(awakeFromNib) {
    my ($self) = @_;
    $self->setNeedInit(1);
}

sub drawRect : Selector(drawRect:) ArgTypes({NSRect=ffff}) {
    my ($self, $rect) = @_;

    # Wake up! Time to draw.
    if ($self->needInit) {
        glOrtho(0.0, 1.0, 0.0, 1.0, -1.0, 1.0);
        $self->setNeedInit(0);
    }

    glClearColor(0.0, 0.0, 0.0, 0.0);
    glColor3f(1.0, 1.0, 1.0);

    glClear(GL_COLOR_BUFFER_BIT);
    glBegin(GL_POLYGON);
        glVertex3f(0.25, 0.25, 0.0);
        glVertex3f(0.75, 0.25, 0.0);
        glVertex3f(0.75, 0.75, 0.0);
        glVertex3f(0.25, 0.75, 0.0);
    glEnd();
    glFlush();
}

1;
