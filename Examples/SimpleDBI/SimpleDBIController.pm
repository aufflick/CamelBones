# SimpleDBI version 0.1, Copyright 2007 Sherm Pendley.

use strict;
use warnings;

package SimpleDBIController;

our $VERSION = "1.0.0";

use CamelBones qw(:All);
use DBI;

our $NSApp;

use constant {
    STATE_INACTIVE => 0,

    STATE_CONNECTING => 1,
    STATE_CONNECTED => 2,
    STATE_QUERYING => 3,
    STATE_RECEIVING => 4,
};

use constant {
    NO => 0,
    YES => 1,
};

our @source_types = (
    'mysql',
    'Pg',
);

class SimpleDBIController {
    'super' => 'NSObject',
    'properties' => [
                        'loginSheet',
                        'sqlWindow',
                        'statusText',
                        'progressSpinner',
                        
                        'progressSheet',
                        'progressBar',
                        'rowsFetched',

                        'sourceType',
                        'availablePopup',
                        
                        'username',
                        'password',
                        
                        'dsn',
                        'dbh',
                        'sth',
                        
                        'tabView',
                        
                        'webview',
                        'html',
                        'css',
                        
                        'sql',
                        
                        'state',
                    ],
};

sub awakeFromNib : Selector(awakeFromNib) {
    my ($self) = @_;

    $NSApp = NSApplication->sharedApplication();

    $NSApp->beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(
        $self->loginSheet,
        $self->sqlWindow,
        $self,
        'sheetDidEnd:returnCode:contextInfo:',
        0,
    );
    
    $self->doRescan($self);
    $self->updateState_withMessage(STATE_INACTIVE, "Welcome to Simple DBI Controller $VERSION");
}

sub updateState_withMessage: Selector(updateState:withMessage) ArgTypes(i@) {
    my ($self, $state, $msg) = @_;

    $self->statusText()->setStringValue( $msg );

    $self->progressSpinner()->stopAnimation($self);

    if ($state == STATE_INACTIVE) {

    } elsif ($state == STATE_CONNECTING) {
        $self->progressSpinner()->startAnimation($self);
    }
    
    $self->setState($state);
}

sub loginSheetDidEnd : Selector(sheetDidEnd:returnCode:contextInfo:)
        ReturnType(v) ArgTypes(@i^v) {
    my ($self, $sheet, $code, $context) = @_;

    $sheet->orderOut($self);
    if ($code == 0) {
        $NSApp->terminate($self);
    }
}

sub doRescan: Selector(doRescan:) IBAction {
    my ($self, $sender) = @_;
    
    my $tag = $self->sourceType()->selectedItem()->tag();
    my $st = $source_types[$tag];

    my @sourceTypes = DBI->data_sources( $st );
    my $ap = $self->availablePopup();
    $ap->removeAllItems();
    $ap->addItemsWithTitles(\@sourceTypes);
}

sub doConnect: Selector(doConnect:) IBAction {
    my ($self, $sender) = @_;
    
    my $ds_title = $self->sourceType()->titleOfSelectedItem();
    my $dsn = $self->availablePopup()->titleOfSelectedItem();
    my $name = $self->username()->stringValue() || '';
    my $password = $self->password()->stringValue() || '';
    (my $passwd = $password) =~ s/./*/g;

    $self->updateState_withMessage(STATE_CONNECTING, "Connecting to $ds_title: DSN=$dsn, USER=$name");

    my $dbh = DBI->connect( $dsn, $name, $password );
    unless ($dbh) {
        $self->updateState_withMessage(STATE_INACTIVE, "Error connecting: " . $DBI::errstr);
        $self->progressSpinner()->stopAnimation($self);
        return;
    }

    $self->setDbh($dbh);
    $self->setDsn($dsn);

    $self->updateState_withMessage(STATE_CONNECTED, "Connected to: $dsn");

    $self->tabView()->selectTabViewItemAtIndex(0);
    $NSApp->endSheet_returnCode($self->loginSheet(), 1);
}

sub terminate : Selector(terminate:) IBAction {
    my ($self, $sender) = @_;

    if ($self->state == STATE_INACTIVE) {
        $NSApp->endSheet_returnCode($self->loginSheet(), 0);
    }
    
    $NSApp->terminate($sender);
}

sub disconnect : Selector(disconnect:) IBAction {
    my ($self, $sender) = @_;
    
    $self->dbh()->disconnect();
    $self->setDbh(undef);

    $self->updateState_withMessage(STATE_INACTIVE, 'Logging In' );

    $NSApp->beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(
        $self->loginSheet,
        $self->sqlWindow,
        $self,
        'sheetDidEnd:returnCode:contextInfo:',
        0,
    );

}

sub go : Selector(go:) IBAction {
    my ($self, $sender) = @_;

    my $sql = $self->sql()->textStorage()->string();
    my $dbh = $self->dbh();
    my $dsn = $self->dsn();
    
    $self->updateState_withMessage(STATE_QUERYING, "Preparing query...");

    my $sth = $dbh->prepare($sql);

    if ($dbh->err()) {
        NSBeginAlertSheet("SQL Error", "OK", undef, undef,
            $self->sqlWindow, $self, undef, undef, 0, $dbh->errstr());
        $self->updateState_withMessage(STATE_CONNECTED, "Connected to: $dsn");
        return;
    }

    $self->updateState_withMessage(STATE_QUERYING, "Executing query...");

    $sth->execute();
    
    if ($sth->err()) {
        NSBeginAlertSheet("SQL Error", "OK", undef, undef,
            $self->sqlWindow, $self, undef, undef, 0, $sth->errstr());
        $self->updateState_withMessage(STATE_CONNECTED, "Connected to: $dsn");
        return;
    }

    $self->updateState_withMessage(STATE_RECEIVING, "Fetching Results...");

    $NSApp->beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo(
        $self->progressSheet,
        $self->sqlWindow,
        $self,
        'fetchDidEnd:returnCode:contextInfo:',
        0,
    );
    $self->progressBar()->startAnimation($self);

    my $html = "<html><head><title>SQL Query Results</title></head><body>\n";
    $html .= "<h1>Query:</h1>\n";
    $html .= "<pre>$sql</pre>\n";
    $html .= "<h1>Results:</h1>\n";
    $html .= "<table>\n";

    $html .= '<tr>';
    foreach my $name ( @{$sth->{'NAME_lc'}} ) {
        $html .= "<th>$name</th>";
    }
    $html .= "</tr>\n";

    my $timer = NSTimer->scheduledTimerWithTimeInterval_target_selector_userInfo_repeats(
        0.0, $self, 'fetchTimerFired:', 0, YES);
    
    $self->setRowsFetched(0);
    $self->setHtml($html);
    $self->setSth($sth);
}

sub fetchTimerFired : Selector(fetchTimerFired:) ReturnType(v) ArgTypes(@) {
    my ($self, $timer) = @_;

    my @row = $self->sth()->fetchrow_array();

    if (@row) {
        my $html = $self->html();
        $html .= '<tr>';
        foreach my $col (@row) {
            $html .= '<td>';
            $html .= $col ? $col : '';
            $html .= '</td>';
        }
        $html .= "</tr>\n";
        $self->setHtml($html);

    } else {
        my $html = $self->html();
        $html .= '</table></body></html>';

        $self->webview()->mainFrame()->loadHTMLString_baseURL($html, NSURL->URLWithString('http://localhost'));
        $self->tabView()->selectTabViewItemAtIndex(1);

        $timer->invalidate();
        $NSApp->endSheet_returnCode($self->progressSheet, 0);
    }
}

sub cancelFetch : Selector(cancelFetch:) IBAction {
    my ($self, $sender) = @_;
    
    $NSApp->endSheet_returnCode($self->progressSheet, 1);
}

sub fetchDidEnd : Selector(fetchDidEnd:returnCode:contextInfo:)
        ReturnType(v) ArgTypes(@i^v) {
    my ($self, $sheet, $code, $context) = @_;
    my $dsn = $self->dsn();

    $self->updateState_withMessage(STATE_CONNECTED, "Connected to: $dsn");
    $self->progressBar()->stopAnimation($self);
    $sheet->orderOut($self);
}

1;
