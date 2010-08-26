use strict;
use warnings;

package MyWindowController;

use CamelBones qw(:All);

class MyWindowController {
	'super' => 'NSObject',
	'properties' => [
					 'window', 'progressBar', 'progressSheet',
					 'timerLength', 'timerFrequency',
					 'windowController',
					 ],
};

sub init : Selector(init) ReturnType(@) {
	my ($self) = @_;

    # Private ivars
    $self->{'_timer'} = undef;

    $self->setWindowController(NSWindowController->alloc->initWithWindowNibName_owner("MainWindow", $self));
    $self->windowController()->window();

    return $self;
}

sub startTimer :
		Selector(startTimer:)
		IBAction
	{
    my ($self, $sender) = @_;

    # Get the timer info
    my $max = $self->timerLength()->floatValue();
    my $interval = $self->timerFrequency()->floatValue();

    # Create the timer
    $self->{'_timer'} = NSTimer->scheduledTimerWithTimeInterval_target_selector_userInfo_repeats(
        $interval, $self, 'timerFired:', {}, 1);

    # Set up the progress bar
    $self->progressBar()->setMinValue(0);
    $self->progressBar()->setMaxValue($max);
    $self->progressBar()->setDoubleValue(0);

    # Display the progress sheet
    my $nsApp = NSApplication->sharedApplication;
    $nsApp->beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(
        $self->progressSheet(), $self->window(), $self,'sheetDidEnd:returnCode:contextInfo:',undef
    );
}

sub timerFired :
		Selector(timerFired:)
		ArgTypes(@) ReturnType(v)
	{
    my ($self, $timer) = @_;

    my $interval = $timer->timeInterval();
    my $progressBar = $self->progressBar();
    my $nsApp = NSApplication->sharedApplication;

    $progressBar->incrementBy($interval);
    if ($progressBar->doubleValue() >= $progressBar->maxValue()) {
        $timer->invalidate();
        $nsApp->endSheet_returnCode($self->progressSheet(), 1);
    }
}

sub cancelTimer :
		Selector(cancelTimer:)
		IBAction
	{
    my ($self, $sender) = @_;
    my $nsApp = NSApplication->sharedApplication;
    if ($self->{'_timer'}) {
        $self->{'_timer'}->invalidate();
    }
    $nsApp->endSheet_returnCode($self->progressSheet(), 0);
}

sub sheetDidEnd_returnCode_contextInfo :
		Selector(sheetDidEnd:returnCode:contextInfo:)
		ArgTypes(@i^v) ReturnType(v)
	{
    my ($self, $sheet, $returnCode) = @_;
    my $nsApp = NSApplication->sharedApplication;

    $sheet->close();
}

1;
