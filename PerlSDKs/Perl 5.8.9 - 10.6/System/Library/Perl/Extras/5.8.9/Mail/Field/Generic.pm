# Copyrights 1995-2008 by Mark Overmeer <perl@overmeer.net>.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.05.
package Mail::Field::Generic;
use vars '$VERSION';
$VERSION = '2.04';


use Carp;
use base 'Mail::Field';


sub create
{   my ($self, %arg) = @_;
    $self->{Text} = delete $arg{Text};

    croak "Unknown options " . join(",", keys %arg)
       if %arg;

    $self;
}


sub parse
{   my $self = shift;
    $self->{Text} = shift || "";
    $self;
}

sub stringify { shift->{Text} }

1;
