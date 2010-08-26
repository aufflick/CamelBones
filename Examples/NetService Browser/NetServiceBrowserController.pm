# NetServiceBrowserController.pm version 0.1, Copyright 2004-2007 Sherman Pendley.

use strict;
use warnings;

package NetServiceBrowserController;

use CamelBones qw(:All);

use Socket;

class NetServiceBrowserController {
    'super' => 'NSObject',
    'properties' => [ qw(
        domainBrowser

        domainList
        serviceBox
        serviceList
        transportBox
        browseButton
        browseAllDomains

        browsers
        services
        domains
    ) ],
};

sub awakeFromNib : Selector(awakeFromNib) {
    my ($self) = @_;

    $self->setBrowsers( {} );
    $self->setServices( [] );
    $self->setDomains( [] );
    $self->serviceList->setDataSource($self);

	$self->updateDomainList();
    $self->updateSearchButtonLabel();

    return $self;
}

# Action methods
sub toggleDomainsList : Selector(toggleDomainsList:) IBAction {
	my ($self, $sender) = @_;
	$self->setValue_forKey($sender->state(), 'browseAllDomains');
	$self->updateDomainList();
}

sub serviceChanged : Selector(serviceChanged:) IBAction {
    my ($self, $sender) = @_;
    $self->updateSearchButtonLabel();
}

sub transportChanged : Selector(transportChanged:) IBAction {
    my ($self, $sender) = @_;
    $self->updateSearchButtonLabel();
}

sub browseServices : Selector(browseServices:) IBAction {
	my ($self, $sender) = @_;

	my $type = $self->serviceBox()->stringValue();
	my $transport = $self->transportBox()->stringValue();
	my $domain = $self->domainList()->titleOfSelectedItem();
    my $key = "$type.$transport.";

    my $browsers = $self->browsers();
    my $services = $self->services();

	# If we're searching, stop the search
    if (exists $browsers->{$key}) {
        my $browser = delete $browsers->{$key};
        $browser->stop();
        $browser->autorelease();
        for (my $i=@$services-1; $i >= 0; $i--) {
            if ($services->[$i]->[1] eq $key) {
                splice @$services, $i, 1;
            }
        }
        $self->serviceList()->reloadData();
    } else {
        my $browser = NSNetServiceBrowser->alloc()->init();
        $browser->setDelegate($self);
        $browser->searchForServicesOfType_inDomain($key, $domain);
        $browsers->{$key} = $browser;
    }
    
    $self->updateSearchButtonLabel();
}

# NSNetServiceBrowser delegate methods
sub netServiceBrowser_didFindDomain_moreComing :
		Selector(netServiceBrowser:didFindDomain:moreComing:)
		ArgTypes(@@c) ReturnType(v)
	{
	my ($self, $browser, $domain, $more) = @_;
	
	# Add this domain to the list
	my $domains = $self->domains();
	push @$domains, $domain;

	# If there are no more, stop the search, close the sheet, and update the pop-up
	if ($more == 0) {
        $self->domainBrowser()->stop();
		foreach my $dom (sort @$domains) {
			$self->domainList()->addItemWithTitle($dom);
		}
	}
}

sub netServiceBrowser_didFindService_moreComing :
		Selector(netServiceBrowser:didFindService:moreComing:)
		ArgTypes(@@c) ReturnType(v)
	{
	my ($self, $browser, $service, $more) = @_;

	# Make ourself the delegate and tell it to resolve its address
	$service->setDelegate($self);

    if ($service->respondsToSelector("resolveWithTimeout:")) {
    	$service->resolveWithTimeout(5);
    } else {
    	$service->resolve();
    }
}

sub netServiceBrowser_didRemoveService_moreComing :
		Selector(netServiceBrowser:didRemoveService:moreComing:)
		ArgTypes(@@c) ReturnType(v)
	{
    my ($self, $browser, $service, $more) = @_;

    my $services = $self->services();
    
    for (my $i=@$services-1; $i >=0; $i--) {
        my $svc = $services->[$i];
        if ($svc->[0] eq $service->name() && $svc->[1] eq $service->type()) {
            splice @$services, $i, 1;
        }
    }

    unless ($more) {
        $self->serviceList()->reloadData();
    }
}

sub netServiceDidResolveAddress :
		Selector(netServiceDidResolveAddress:)
		ArgTypes(@) ReturnType(v)
	{
	my ($self, $service) = @_;

	# Get the name and type - if only everything were this simple...
	my $name = $service->name();
	my $type = $service->type();

	# Loop over the addresses, which are an NSArray of NSData objects
	# Each NSData object contains a C sockaddr structure
	foreach my $obj ($service->addresses()) {

		# The bytes method returns a pointer, which is passed to Perl as a
		# long int. First, "promote" this int into a pointer with pack().
		my $bytes = pack('L', $obj->bytes());

		# Get the structure family and size
		# Resolve the pointer created above into an opaque two-byte data structure
		my $sockaddr = unpack('P2', $bytes);
		
		# Now unpack the two-byte structure created above into two char
		# size integers.
		my ($size, $family) = unpack('cc', $sockaddr);

		# For AF_INET sockets, get the address and make it printable
		if ($family == AF_INET) {

			# Similar to resolving the pointer above, but make the result
			# point to a structure of $size bytes.
			#
			# Pass the result directly to sockaddr_in(), instead of
			# unpacking it further.

			my ($port, $address) = sockaddr_in(unpack("P$size", $bytes));
			$address = inet_ntoa($address);
			$self->addToServicesList($name, $type, $address, $port);

		# For AF_UNIX sockets, get the path
		} elsif ($family == AF_UNIX) {
		
			# Similar to above, but don't transform the path
			my ($port, $path) = sockaddr_un(unpack("P$size", $bytes));
			$self->addToServicesList($name, $type, $path, $port);
		}
		
		# Reload the list
		$self->serviceList()->reloadData();
	}
}

# Data source methods
sub numberOfRowsInTableView :
		Selector(numberOfRowsInTableView:)
		ArgTypes(@) ReturnType(i)
	{
    my $self = shift;
    return scalar @{$self->{'services'}};
}

sub tableView_objectValueForTableColumn_row :
		Selector(tableView:objectValueForTableColumn:row:)
		ArgTypes(@@i) ReturnType(@)
	{
    my ($self, $tableView, $tableColumn, $row) = @_;
    my $services = $self->services();
    return $services->[$row]->[$tableColumn->identifier];
}

# Internal methods
sub addToServicesList {
	my ($self, $name, $type, $address, $port) = @_;

    my $services = $self->services();

	# Scan to see if it's already here
	foreach my $service (@$services) {
		if (
			$service->[0] eq $name &&
			$service->[1] eq $type &&
			$service->[2] eq $address &&
			$service->[3] eq $port
		) {
			return;
		}
	}
	
	# It's not, so push it
	push @$services, [$name, $type, $address, $port];
}

sub checkDomainBrowser {
	my ($self) = @_;

	# If there's no service browser yet, create one
	unless (defined $self->domainBrowser()) {
		$self->setDomainBrowser(NSNetServiceBrowser->alloc()->init());
		$self->domainBrowser()->setDelegate($self);
	}
}

sub updateDomainList {
	my ($self) = @_;
	$self->checkDomainBrowser();
	
	# Clear out the old list
	$self->domainList()->removeAllItems();
	$self->setDomains( [] );
	
	# Tell the browser to begin searching
	if ($self->browseAllDomains()) {
		$self->domainBrowser()->searchForAllDomains();
	} else {
		$self->domainBrowser()->searchForRegistrationDomains();
	}
}

sub updateSearchButtonLabel {
    my ($self) = @_;

    my $service = $self->serviceBox()->stringValue();
    my $transport = $self->transportBox()->stringValue();
    my $key = "$service.$transport.";

    my $browsers = $self->browsers();
    if (exists $browsers->{$key}) {
        $self->browseButton()->setTitle("Stop");
    } else {
        $self->browseButton()->setTitle("Browse");
    }
}

1;
