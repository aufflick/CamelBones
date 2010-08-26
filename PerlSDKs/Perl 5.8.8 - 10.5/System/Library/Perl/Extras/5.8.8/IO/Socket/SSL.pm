#!/usr/bin/perl -w
#
# IO::Socket::SSL: 
#    a drop-in replacement for IO::Socket::INET that encapsulates
#    data passed over a network with SSL.
#
# Current Code Shepherd: Peter Behroozi, <behrooz at fas.harvard.edu>
#
# The original version of this module was written by 
# Marko Asplund, <marko.asplund at kronodoc.fi>, who drew from
# Crypt::SSLeay (Net::SSL) by Gisle Aas.
#

package IO::Socket::SSL;

use IO::Socket;
use Net::SSLeay 1.21;
use Exporter ();
use Scalar::Util 'dualvar';
use Errno 'EAGAIN';
use Carp;
use strict;

use vars qw(@ISA $VERSION $DEBUG $SSL_ERROR $GLOBAL_CONTEXT_ARGS @EXPORT );

{
    # These constants will be used in $! at return from SSL_connect, 
    # SSL_accept, generic_read and write, thus notifying the caller
    # the usual way of problems. Like with EAGAIN, EINPROGRESS..
    # these are especially important for non-blocking sockets

    my $x = Net::SSLeay::ERROR_WANT_READ();
    use constant SSL_WANT_READ  => dualvar( \$x, 'SSL wants a read first' );
    my $y = Net::SSLeay::ERROR_WANT_WRITE();
    use constant SSL_WANT_WRITE => dualvar( \$y, 'SSL wants a write first' );

    @EXPORT = qw( SSL_WANT_READ SSL_WANT_WRITE $SSL_ERROR );
}

BEGIN {
    # Declare @ISA, $VERSION, $GLOBAL_CONTEXT_ARGS
    @ISA = qw(IO::Socket::INET);
    $VERSION = '0.999';
    $GLOBAL_CONTEXT_ARGS = {};

    #Make $DEBUG another name for $Net::SSLeay::trace
    *DEBUG = \$Net::SSLeay::trace;

    #Compability
    *ERROR = \$SSL_ERROR;

    # Do Net::SSLeay initialization
    Net::SSLeay::load_error_strings();
    Net::SSLeay::SSLeay_add_ssl_algorithms();
    Net::SSLeay::randomize();

}

# Export some stuff
# inet4|inet6|debug will be handeled by myself, everything
# else will be handeld the Exporter way
sub import { 
    my $class = shift;

    my @export;
    foreach (@_) { 
	@ISA=qw(IO::Socket::INET), next if /inet4/i;
	@ISA=qw(IO::Socket::INET6), next if /inet6/i;
	$DEBUG=$1, next if /debug(\d)/; 
	push @export,$_
    }

    @_ = ( $class,@export );
    goto &Exporter::import;
}

# You might be expecting to find a new() subroutine here, but that is
# not how IO::Socket::INET works.  All configuration gets performed in
# the calls to configure() and either connect() or accept().

#Call to configure occurs when a new socket is made using
#IO::Socket::INET.  Returns false (empty list) on failure.
sub configure {
    my ($self, $arg_hash) = @_;
    return _invalid_object() unless($self);

    # force initial blocking 
    # otherwise IO::Socket::SSL->new might return undef if the
    # socket is nonblocking and it fails to connect immediatly
    # for real nonblocking behavior one should create a nonblocking
    # socket and later call connect explicitly
    my $blocking = delete $arg_hash->{Blocking};
    $arg_hash->{Blocking} = 1;

    $self->configure_SSL($arg_hash) || return;

    $self->SUPER::configure($arg_hash)
	|| return $self->error("@ISA configuration failed");

    $self->blocking(0) if defined $blocking && !$blocking;
    return $self;
}

sub configure_SSL {
    my ($self, $arg_hash) = @_;

    my $is_server = $arg_hash->{'SSL_server'} || $arg_hash->{'Listen'} || 0;
    my %default_args =
	('Proto'         => 'tcp',
	 'SSL_server'    => $is_server,
	 'SSL_ca_file'   => 'certs/my-ca.pem',
	 'SSL_ca_path'   => 'ca/',
	 'SSL_use_cert'  => $is_server,
	 'SSL_check_crl' => 0,
	 'SSL_version'   => 'sslv23',
	 'SSL_verify_mode' => Net::SSLeay::VERIFY_NONE(),
	 'SSL_verify_callback' => 0,
    );
     
    # SSL_key_file and SSL_cert_file will only be set in defaults if 
    # SSL_key|SSL_key_file resp SSL_cert|SSL_cert_file are not set in
    # $args_hash
    foreach my $k (qw( key cert )) {
	next if exists $arg_hash->{ "SSL_${k}" };
	next if exists $arg_hash->{ "SSL_${k}_file" };
    	$default_args{ "SSL_${k}_file" } = $is_server 
	    ?  "certs/server-${k}.pem" 
	    :  "certs/client-${k}.pem";
    }	

    #Replace nonexistent entries with defaults
    %$arg_hash = ( %default_args, %$GLOBAL_CONTEXT_ARGS, %$arg_hash );

    #Avoid passing undef arguments to Net::SSLeay
    !defined($arg_hash->{$_}) and ($arg_hash->{$_} = '') foreach (keys %$arg_hash);

    #Handle CA paths properly if no CA file is specified
    if ($arg_hash->{'SSL_ca_path'} ne '' and !(-f $arg_hash->{'SSL_ca_file'})) {
	warn "CA file $arg_hash->{'SSL_ca_file'} not found, using CA path instead.\n" if ($DEBUG);
	$arg_hash->{'SSL_ca_file'} = '';
    }

    ${*$self}{'_SSL_arguments'} = $arg_hash;
    ${*$self}{'_SSL_ctx'} = IO::Socket::SSL::SSL_Context->new($arg_hash) || return;
    ${*$self}{'_SSL_opened'} = 1 if ($is_server);

    return $self;
}


sub _set_rw_error {
    my ($self,$ssl,$rv) = @_;
    my $err = Net::SSLeay::get_error($ssl,$rv);
    $SSL_ERROR = 
	$err == Net::SSLeay::ERROR_WANT_READ()  ? SSL_WANT_READ :
	$err == Net::SSLeay::ERROR_WANT_WRITE() ? SSL_WANT_WRITE :
	return;
    $! ||= EAGAIN;
    ${*$self}{'_SSL_last_err'} = $SSL_ERROR if (ref($self));
    return 1;
}


#Call to connect occurs when a new client socket is made using
#IO::Socket::INET
sub connect {
    my $self = shift || return _invalid_object();
    return $self if ${*$self}{'_SSL_opened'};  # already connected

    if ( ! ${*$self}{'_SSL_opening'} ) {
	# call SUPER::connect if the underlying socket is not connected
	# if this fails this might not be an error (e.g. if $! = EINPROGRESS
	# and socket is nonblocking this is normal), so keep any error
	# handling to the client
	#DEBUG( 'socket not yet connected' );
	$self->SUPER::connect(@_) || return;
	#DEBUG( 'socket connected' );
    }
    return $self->connect_SSL;
}


sub connect_SSL {
    my $self = shift;

    my ($ssl,$ctx);
    if ( ! ${*$self}{'_SSL_opening'} ) {
	# start ssl connection
	#DEBUG( 'ssl handshake not started' );
	${*$self}{'_SSL_opening'} = 1;
	my $arg_hash = ${*$self}{'_SSL_arguments'};

	my $fileno = ${*$self}{'_SSL_fileno'} = fileno($self);
	return $self->error("Socket has no fileno") unless (defined $fileno);

	$ctx = ${*$self}{'_SSL_ctx'};  # Reference to real context
	$ssl = ${*$self}{'_SSL_object'} = Net::SSLeay::new($ctx->{context})
	    || return $self->error("SSL structure creation failed");

	Net::SSLeay::set_fd($ssl, $fileno)
	    || return $self->error("SSL filehandle association failed");

	if ( my $cl = $arg_hash->{SSL_cipher_list} ) {
	    Net::SSLeay::set_cipher_list($ssl, $cl )
	    	|| return $self->error("Failed to set SSL cipher list");
	}

	my $session = $ctx->session_cache( $arg_hash->{PeerAddr}, $arg_hash->{PeerPort} );
	Net::SSLeay::set_session($ssl, $session) if ($session);
    }

    $ssl ||= ${*$self}{'_SSL_object'};

    $SSL_ERROR = undef;
    #DEBUG( 'calling ssleay::connect' );
    my $rv = Net::SSLeay::connect($ssl);
    #DEBUG( "rv=$rv" );
    if ( $rv < 0 ) {
	unless ( $self->_set_rw_error( $ssl,$rv )) {
	    $self->error("SSL connect attempt failed with unknown error");
	    delete ${*$self}{'_SSL_opening'};
	    ${*$self}{'_SSL_opened'} = 1;
	    return $self->fatal_ssl_error();
	}
	#DEBUG( 'ssl handshake in progress' );
	return;
    } elsif ( $rv == 0 ) {
	delete ${*$self}{'_SSL_opening'};
	$self->error("SSL connect attempt failed because of handshake problems" );
	${*$self}{'_SSL_opened'} = 1;
	return $self->fatal_ssl_error();
    }

    #DEBUG( 'ssl handshake done' );
    # ssl connect successful
    delete ${*$self}{'_SSL_opening'};
    ${*$self}{'_SSL_opened'}=1;

    $ctx ||= ${*$self}{'_SSL_ctx'};
    if ( $ctx->has_session_cache ) {
	my $arg_hash = ${*$self}{'_SSL_arguments'};
	my ($addr,$port) = ( $arg_hash->{PeerAddr}, $arg_hash->{PeerPort} );
	my $session = $ctx->session_cache( $addr,$port );
	$ctx->session_cache( $addr,$port, Net::SSLeay::get1_session($ssl) ) if !$session;
    }

    tie *{$self}, "IO::Socket::SSL::SSL_HANDLE", $self;

    return $self;
}


#Call to accept occurs when a new client connects to a server using
#IO::Socket::SSL
sub accept {
    my $self = shift || return _invalid_object();
    my $class = shift || 'IO::Socket::SSL';

    my $socket = ${*$self}{'_SSL_opening'};
    if ( ! $socket ) {
	# underlying socket not done
	#DEBUG( 'no socket yet' );
	$socket = $self->SUPER::accept($class) || return;
	#DEBUG( 'accept created normal socket '.$socket );
    }

    $self->accept_SSL($socket) || return;
    #DEBUG( 'accept_SSL ok' );

    return wantarray ? ($socket, getpeername($socket) ) : $socket;
}

sub accept_SSL {
    my ($self,$socket) = @_;
    $socket ||= $self;

    my $ssl;
    if ( ! ${*$self}{'_SSL_opening'} ) {
	#DEBUG( 'starting sslifying' );
	${*$self}{'_SSL_opening'} = $socket;
	my $arg_hash = ${*$self}{'_SSL_arguments'};
	${*$socket}{'_SSL_arguments'} = { %$arg_hash, SSL_server => 0 };
	my $ctx = ${*$socket}{'_SSL_ctx'} = ${*$self}{'_SSL_ctx'};

	my $fileno = ${*$socket}{'_SSL_fileno'} = fileno($socket);
	return $socket->error("Socket has no fileno") unless (defined $fileno);

	$ssl = ${*$socket}{'_SSL_object'} = Net::SSLeay::new($ctx->{context})
	    || return $socket->error("SSL structure creation failed");

	Net::SSLeay::set_fd($ssl, $fileno)
	    || return $socket->error("SSL filehandle association failed");

	if ( my $cl = $arg_hash->{SSL_cipher_list} ) {
	    Net::SSLeay::set_cipher_list($ssl, $cl )
		|| return $socket->error("Failed to set SSL cipher list");
	}
    }

    $ssl ||= ${*$socket}{'_SSL_object'};

    $SSL_ERROR = undef;
    #DEBUG( 'calling ssleay::accept' );
    my $rv = Net::SSLeay::accept($ssl);
    #DEBUG( 'called ssleay::accept rv='.$rv );
    if ( $rv < 0 ) {
	unless ( $socket->_set_rw_error( $ssl,$rv )) {
	    $socket->error("SSL accept attempt failed with unknown error");
	    delete ${*$self}{'_SSL_opening'};
    	    ${*$socket}{'_SSL_opened'} = 1;
	    return $socket->fatal_ssl_error();
	}
	return;
    } elsif ( $rv == 0 ) {
	$socket->error("SSL connect accept failed because of handshake problems" );
	delete ${*$self}{'_SSL_opening'};
	${*$socket}{'_SSL_opened'} = 1;
	return $socket->fatal_ssl_error();
    }

    #DEBUG( 'handshake done, socket ready' );
    # socket opened
    delete ${*$self}{'_SSL_opening'};
    ${*$socket}{'_SSL_opened'} = 1;

    tie *{$socket}, "IO::Socket::SSL::SSL_HANDLE", $socket;

    return $socket;
}


####### I/O subroutines ########################

sub generic_read {
    my ($self, $read_func, undef, $length, $offset) = @_;
    my $ssl = $self->_get_ssl_object || return;
    my $buffer=\$_[2];
    
    $SSL_ERROR = undef;
    my $data = $read_func->($ssl, $length);
    if ( !defined($data)) {
	$self->_set_rw_error( $ssl,-1 ) || $self->error("SSL read error");
	return;
    }
    
    $length = length($data);
    $$buffer = '' if !defined $$buffer;
    $offset ||= 0;
    if ($offset>length($$buffer)) {
	$$buffer.="\0" x ($offset-length($$buffer));  #mimic behavior of read
    }

    substr($$buffer, $offset, length($$buffer), $data);
    return $length;
}

sub read {
    my $self = shift;
    return $self->generic_read( 
	$self->blocking ? \&Net::SSLeay::ssl_read_all : \&Net::SSLeay::read, 
	@_ 
    );
}

# contrary to the behavior of read sysread can read partial data
sub sysread {
    my $self = shift;
    return $self->generic_read( \&Net::SSLeay::read, @_ );
}

sub peek {
    my $self = shift;
    if (Net::SSLeay::OPENSSL_VERSION_NUMBER() >= 0x0090601f) {
	return $self->generic_read(\&Net::SSLeay::peek, @_);
    } else {
	return $self->error("SSL_peek not supported for OpenSSL < v0.9.6a");
    }
}


sub generic_write {
    my ($self, $write_all, undef, $length, $offset) = @_;

    my $ssl = $self->_get_ssl_object || return;
    my $buffer = \$_[2];

    my $buf_len = length($$buffer);
    $length ||= $buf_len;
    $offset ||= 0;
    return $self->error("Invalid offset for SSL write") if ($offset>$buf_len);
    return 0 if ($offset == $buf_len);

    $SSL_ERROR = undef;
    my $written;
    if ( $write_all ) {
    	my $data = $length < $buf_len-$offset ? substr($$buffer, $offset, $length) : $$buffer;
	$written = Net::SSLeay::ssl_write_all($ssl, $data);
    } else {
	$written = Net::SSLeay::write_partial( $ssl,$offset,$length,$$buffer );
    }
    $written = undef if $written < 0; # Net::SSLeay::write returns -1 not undef on error
    if ( !defined($written) ) {
	$self->_set_rw_error( $ssl,-1 )
	    || $self->error("SSL write error");
	return;
    }

    return $written;
}

# if socket is blocking write() should return only on error or
# if all data are written
sub write {
    my $self = shift;
    return $self->generic_write( $self->blocking,@_ );
}

# contrary to write syswrite() returns already if only
# a part of the data is written
sub syswrite {
    my $self = shift;
    return $self->generic_write( 0,@_ );
}

sub print {
    my $self = shift;
    my $string = join(($, or ''), @_, ($\ or ''));
    return $self->write( $string );
}

sub printf {
    my ($self,$format) = (shift,shift);
    return $self->write(sprintf($format, @_));
}

sub getc {
    my ($self, $buffer) = (shift, undef);
    return $buffer if $self->read($buffer, 1, 0);
}

sub readline {
    my $self = shift;
    my $ssl = $self->_get_ssl_object || return;

    if (wantarray) {
	my ($buf,$err) = Net::SSLeay::ssl_read_all($ssl);
	return $self->error( "SSL read error" ) if $err;
	if ( !defined($/) ) {
	    return $buf;
	} elsif ( ref($/) ) {
	    my $size = ${$/};
	    die "bad value in ref \$/: $size" unless $size>0;
	    return $buf=~m{\G(.{1,$size})}g;
	} elsif ( $/ eq '' ) {
	    return $buf =~m{\G(.*\n\n+|.+)}g;
	} else {
	    return $buf =~m{\G(.*$/|.+)}g;
	}
    }

    if ( !defined($/) ) {
	my ($buf,$err) = Net::SSLeay::ssl_read_all($ssl);
	return $self->error( "SSL read error" ) if $err;
	return $buf;
    } elsif ( ref($/) ) {
	my $size = ${$/};
	die "bad value in ref \$/: $size" unless $size>0;
	my ($buf,$err) = Net::SSLeay::ssl_read_all($ssl,$size);
	return $self->error( "SSL read error" ) if $err;
	return $buf;
    } elsif ( $/ ne '' ) {
    	my $line = Net::SSLeay::ssl_read_until($ssl,$/);
	return $self->error( "SSL read error" ) if $line eq '';
	return $line;
    } else {
	# $/ is ''
	# ^.*?\n\n+, need peek to find all \n at the end
    	die "empty \$/ is not supported if I don't have peek"
	    if Net::SSLeay::OPENSSL_VERSION_NUMBER() < 0x0090601f;

	# find first occurence of \n\n
	my $buf = '';
	my $eon = 0;
	while (1) { 
	    defined( Net::SSLeay::peek($ssl,1)) || last; # peek more, can block
	    my $pending = Net::SSLeay::pending($ssl);
	    $buf .= Net::SSLeay::peek( $ssl,$pending );  # will not block
	    if ( !$eon ) {
	    	my $pos = index( $buf,"\n\n");
		next if $pos<0; # newlines not found
		$eon = $pos+2;  # pos after second newline
	    }
	    # $eon >= 2  == bytes incl last known \n
	    while ( index( $buf,"\n",$eon ) == $eon ) {
	    	# the next char ist \n too
		$eon++;
	    }
	    last if $eon < length($buf); # found last \n before end of buf
	}
	if ( $eon > 0 ) {
	    # found something
	    # readed peeked data until $eon from $ssl
	    return Net::SSLeay::ssl_read_all( $ssl,$eon );
	} else {
	    # found nothing
	    # return all what we have
	    if ( my $l = length($buf)) {
	    	return Net::SSLeay::ssl_read_all( $ssl,$l );
	    } else {
	    	return $self->error( "SSL read error" );
	    }
	}
    }
}

sub close {
    my $self = shift || return _invalid_object();
    my $close_args = (ref($_[0]) eq 'HASH') ? $_[0] : {@_};
    return $self->error("SSL object already closed") unless (${*$self}{'_SSL_opened'});

    if (my $ssl = ${*$self}{'_SSL_object'}) {
	local $SIG{PIPE} = sub{};
	$close_args->{'SSL_no_shutdown'} or Net::SSLeay::shutdown($ssl);
	Net::SSLeay::free($ssl);
	delete ${*$self}{'_SSL_object'};
    }

    if ($close_args->{'SSL_ctx_free'}) {
	my $ctx = ${*$self}{'_SSL_ctx'};
	delete ${*$self}{'_SSL_ctx'};
	$ctx->DESTROY();
    }

    if (${*$self}{'_SSL_certificate'}) {
	Net::SSLeay::X509_free(${*$self}{'_SSL_certificate'});
    }

    ${*$self}{'_SSL_opened'} = 0;
    my $arg_hash = ${*$self}{'_SSL_arguments'};
    untie(*$self) unless ($arg_hash->{'SSL_server'}
			  or $close_args->{_SSL_in_DESTROY});

    $self->SUPER::close unless ($close_args->{_SSL_in_DESTROY});
}

sub kill_socket {
    my $self = shift;
    shutdown($self, 2);
    $self->close(SSL_no_shutdown => 1) if (${*$self}{'_SSL_opened'});
    delete(${*$self}{'_SSL_ctx'});
    return;
}

sub fileno {
    my $self = shift;
    my $fn = ${*$self}{'_SSL_fileno'};
	return defined($fn) ? $fn : $self->SUPER::fileno();
}


####### IO::Socket::SSL specific functions #######
# _get_ssl_object is for internal use ONLY!
sub _get_ssl_object {
    my $self = shift;
    my $ssl = ${*$self}{'_SSL_object'};
    return IO::Socket::SSL->error("Undefined SSL object") unless($ssl);
    return $ssl;
}

# default error for undefined arguments
sub _invalid_object {
    return IO::Socket::SSL->error("Undefined IO::Socket::SSL object");
}


sub pending {
    my $ssl = shift()->_get_ssl_object || return;
    return Net::SSLeay::pending($ssl);
}

sub start_SSL {
    my ($class,$socket) = (shift,shift);
    return $class->error("Not a socket") unless(ref($socket));
    my $arg_hash = (ref($_[0]) eq 'HASH') ? $_[0] : {@_};
    my $original_class = ref($socket);
    my $original_fileno = (UNIVERSAL::can($socket, "fileno"))
	? $socket->fileno : CORE::fileno($socket);
    return $class->error("Socket has no fileno") unless defined $original_fileno;

    bless $socket, $class;
    $socket->configure_SSL($arg_hash) or bless($socket, $original_class) && return;

    ${*$socket}{'_SSL_fileno'} = $original_fileno;

    my $start_handshake = $arg_hash->{SSL_startHandshake};
    if ( ! defined($start_handshake) || $start_handshake ) {
	# if we have no callback force blocking mode
	#DEBUG( "start handshake" );
	my $blocking = $socket->blocking(1);
	my $result = ${*$socket}{'_SSL_arguments'}{SSL_server}
	    ? $socket->accept_SSL
	    : $socket->connect_SSL;
	$socket->blocking(0) if !$blocking;
    	return $result ? $socket : (bless($socket, $original_class) && ());
    } else {
	#DEBUG( "dont start handshake: $socket" );
    	return $socket; # just return upgraded socket 
    }

}

sub new_from_fd {
    my ($class, $fd) = (shift,shift);
    # Check for accidental inclusion of MODE in the argument list
    if (length($_[0]) < 4) {
	(my $mode = $_[0]) =~ tr/+<>//d;
	shift unless length($mode);
    }
    my $handle = IO::Socket::INET->new_from_fd($fd, '+<')
	|| return($class->error("Could not create socket from file descriptor."));

    # Annoying workaround for Perl 5.6.1 and below:
    $handle = IO::Socket::INET->new_from_fd($handle, '+<');

    return $class->start_SSL($handle, @_);
}


sub dump_peer_certificate {
    my $ssl = shift()->_get_ssl_object || return;
    return Net::SSLeay::dump_peer_certificate($ssl);
}

sub peer_certificate {
    my ($self, $field) = @_;
    my $ssl = $self->_get_ssl_object || return;

    my $cert = ${*$self}{'_SSL_certificate'} ||= Net::SSLeay::get_peer_certificate($ssl) ||
	return $self->error("Could not retrieve peer certificate");

    if ($field) {
	my $name = ($field eq "issuer" or $field eq "authority")
	    ? Net::SSLeay::X509_get_issuer_name($cert)
	    : Net::SSLeay::X509_get_subject_name($cert);

	return $self->error("Could not retrieve peer certificate $field") unless ($name);
	return Net::SSLeay::X509_NAME_oneline($name);
    } else {
    	return $cert
    };
}

sub get_cipher {
    my $ssl = shift()->_get_ssl_object || return;
    return Net::SSLeay::get_cipher($ssl);
}

sub errstr {
    my $self = shift;
    return ((ref($self) ? ${*$self}{'_SSL_last_err'} : $SSL_ERROR) or '');
}

sub fatal_ssl_error {
    my $self = shift;
    my $error_trap = ${*$self}{'_SSL_arguments'}->{'SSL_error_trap'};
    if (defined $error_trap and ref($error_trap) eq 'CODE') {
	$error_trap->($self, $self->errstr()."\n".$self->get_ssleay_error());
    } else { $self->kill_socket; }
    return;
}

sub get_ssleay_error {
    #Net::SSLeay will print out the errors itself unless we explicitly
    #undefine $Net::SSLeay::trace while running print_errs()
    local $Net::SSLeay::trace;
    return Net::SSLeay::print_errs('SSL error: ') || '';
}

sub error {
    my ($self, $error, $destroy_socket) = @_;
    $error .= Net::SSLeay::ERR_error_string(Net::SSLeay::ERR_get_error());
    carp $error."\n".$self->get_ssleay_error() if $DEBUG;
    $SSL_ERROR = dualvar( -1, $error );
    ${*$self}{'_SSL_last_err'} = $SSL_ERROR if (ref($self));
    return;
}


sub DESTROY {
    my $self = shift || return;
    $self->close(_SSL_in_DESTROY => 1, SSL_no_shutdown => 1) if (${*$self}{'_SSL_opened'});
    delete(${*$self}{'_SSL_ctx'});
}


#######Extra Backwards Compatibility Functionality#######
sub socket_to_SSL { IO::Socket::SSL->start_SSL(@_); }
sub socketToSSL { IO::Socket::SSL->start_SSL(@_); }

sub issuer_name { return(shift()->peer_certificate("issuer")) }
sub subject_name { return(shift()->peer_certificate("subject")) }
sub get_peer_certificate { return shift()->peer_certificate() }

sub context_init {
    return($GLOBAL_CONTEXT_ARGS = (ref($_[0]) eq 'HASH') ? $_[0] : {@_});
}

sub set_default_context {
    $GLOBAL_CONTEXT_ARGS->{'SSL_reuse_ctx'} = shift;
}


sub opened {
    my $self = shift;
    return IO::Handle::opened($self) && ${*$self}{'_SSL_opened'};
}

sub opening {
    my $self = shift;
    return ${*$self}{'_SSL_opening'};
}

sub want_read  { shift->errstr == SSL_WANT_READ }
sub want_write { shift->errstr == SSL_WANT_WRITE }


#Redundant IO::Handle functionality
sub getline  { return(scalar shift->readline()) }
sub getlines { if (wantarray()) { return(shift->readline()) }
	       else { croak("Use of getlines() not allowed in scalar context");  }}

#Useless IO::Handle functionality
sub truncate { croak("Use of truncate() not allowed with SSL") }
sub stat     { croak("Use of stat() not allowed with SSL"    ) }
sub setbuf   { croak("Use of setbuf() not allowed with SSL"  ) }
sub setvbuf  { croak("Use of setvbuf() not allowed with SSL" ) }
sub fdopen   { croak("Use of fdopen() not allowed with SSL"  ) }

#Unsupported socket functionality
sub ungetc { croak("Use of ungetc() not implemented in IO::Socket::SSL") }
sub send   { croak("Use of send() not implemented in IO::Socket::SSL; use print/printf/syswrite instead") }
sub recv   { croak("Use of recv() not implemented in IO::Socket::SSL; use read/sysread instead") }

package IO::Socket::SSL::SSL_HANDLE;
use strict;
use vars qw($HAVE_WEAKREF);

BEGIN {
    local ($@, $SIG{__DIE__});

    #Use Scalar::Util or WeakRef if possible:
    eval "use Scalar::Util qw(weaken isweak); 1" or
	eval "use WeakRef";
    $HAVE_WEAKREF = $@ ? 0 : 1;
}

sub TIEHANDLE {
    my ($class, $handle) = @_;
    weaken($handle) if $HAVE_WEAKREF;
    bless \$handle, $class;
}

sub READ     { ${shift()}->sysread  (@_) }
sub READLINE { ${shift()}->readline (@_) }
sub GETC     { ${shift()}->getc     (@_) }

sub PRINT    { ${shift()}->print    (@_) }
sub PRINTF   { ${shift()}->printf   (@_) }
sub WRITE    { ${shift()}->syswrite (@_) }

sub FILENO   { ${shift()}->fileno   (@_) }

sub CLOSE {                          #<---- Do not change this function!
    my $ssl = ${$_[0]};
    local @_;
    $ssl->close();
}


package IO::Socket::SSL::SSL_Context;
use strict;

# should be better taken from Net::SSLeay, but they are not (yet) defined there
use constant SSL_MODE_ENABLE_PARTIAL_WRITE => 1;
use constant SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER => 2;

# Note that the final object will actually be a reference to the scalar
# (C-style pointer) returned by Net::SSLeay::CTX_*_new() so that
# it can be blessed.
sub new {
    my $class = shift;
    my $arg_hash = (ref($_[0]) eq 'HASH') ? $_[0] : {@_};

    my $ctx_object = $arg_hash->{'SSL_reuse_ctx'};
    if ($ctx_object) {
	return $ctx_object if ($ctx_object->isa('IO::Socket::SSL::SSL_Context') and
			       $ctx_object->{context});

	# The following "double entendre" applies only if someone passed
	# in an IO::Socket::SSL object instead of an actual context.
	return $ctx_object if ($ctx_object = ${*$ctx_object}{'_SSL_ctx'});
    }

    my $ctx;
    foreach ($arg_hash->{'SSL_version'}) {
	$ctx = /^sslv2$/i ? Net::SSLeay::CTX_v2_new()    :
	       /^sslv3$/i ? Net::SSLeay::CTX_v3_new()    :
	       /^tlsv1$/i ? Net::SSLeay::CTX_tlsv1_new() :
			    Net::SSLeay::CTX_new();
    }

    $ctx || return IO::Socket::SSL->error("SSL Context init failed");

    Net::SSLeay::CTX_set_options($ctx, Net::SSLeay::OP_ALL());

    # SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER makes syswrite return if at least one
    # buffer was written and not block for the rest
    # SSL_MODE_ENABLE_PARTIAL_WRITE can be necessary for non-blocking because we
    # cannot guarantee, that the location of the buffer stays constant
    Net::SSLeay::CTX_set_mode( $ctx, SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER
    	|SSL_MODE_ENABLE_PARTIAL_WRITE);


    my ($verify_mode, $verify_cb) = @{$arg_hash}{'SSL_verify_mode','SSL_verify_callback'};
    unless ($verify_mode == Net::SSLeay::VERIFY_NONE())
    {
	&Net::SSLeay::CTX_load_verify_locations
	    ($ctx, @{$arg_hash}{'SSL_ca_file','SSL_ca_path'}) ||
	     return IO::Socket::SSL->error("Invalid certificate authority locations");
    }

    if ($arg_hash->{'SSL_check_crl'}) {
	if (Net::SSLeay::OPENSSL_VERSION_NUMBER() >= 0x0090702f)
	{
	    Net::SSLeay::X509_STORE_CTX_set_flags
		(Net::SSLeay::CTX_get_cert_store($ctx),
		 Net::SSLeay::X509_V_FLAG_CRL_CHECK());
	} else {
	    return IO::Socket::SSL->error("CRL not supported for OpenSSL < v0.9.7b");
	}
    }

    if ($arg_hash->{'SSL_server'} || $arg_hash->{'SSL_use_cert'}) {
	my $filetype = Net::SSLeay::FILETYPE_PEM();

	if ($arg_hash->{'SSL_passwd_cb'}) {
	    Net::SSLeay::CTX_set_default_passwd_cb($ctx, $arg_hash->{'SSL_passwd_cb'});
	}

	if ( my $pkey= $arg_hash->{SSL_key} ) {
	    # binary, e.g. EVP_PKEY*
	    Net::SSLeay::CTX_use_PrivateKey($ctx, $pkey)
		|| return IO::Socket::SSL->error("Failed to use Private Key");
	} elsif ( my $f = $arg_hash->{SSL_key_file} ) {
	    Net::SSLeay::CTX_use_PrivateKey_file($ctx, $f, $filetype)
		|| return IO::Socket::SSL->error("Failed to open Private Key");
	}

	if ( my $x509 = $arg_hash->{SSL_cert} ) {
	    # binary, e.g. X509*
	    # we habe either a single certificate or a list with
	    # a chain of certificates
	    my @x509 = ref($x509) eq 'ARRAY' ? @$x509: ($x509);
	    my $cert = shift @x509;
	    Net::SSLeay::CTX_use_certificate( $ctx,$cert ) 
	    	|| return IO::Socket::SSL->error("Failed to use Certificate");
	    foreach my $ca (@x509) {
	    	Net::SSLeay::CTX_add_extra_chain_cert( $ctx,$ca ) 
	    	    || return IO::Socket::SSL->error("Failed to use Certificate");
	    }
	} elsif ( my $f = $arg_hash->{SSL_cert_file} ) {
	    Net::SSLeay::CTX_use_certificate_chain_file($ctx, $f)
		|| return IO::Socket::SSL->error("Failed to open Certificate");
	}

	if ( my $dh = $arg_hash->{SSL_dh} ) {
	    # binary, e.g. DH*
	    Net::SSLeay::CTX_set_tmp_dh( $ctx,$dh )
	    	|| return IO::Socket::SSL->error( "Failed to set DH from SSL_dh" );
	} elsif ( my $f = $arg_hash->{SSL_dh_file} ) {
	    my $bio = Net::SSLeay::BIO_new_file( $f,'r' ) 
	    	|| return IO::Socket::SSL->error( "Failed to open DH file $f" );
	    my $dh = Net::SSLeay::PEM_read_bio_DHparams($bio);
	    Net::SSLeay::BIO_free($bio);
	    $dh || return IO::Socket::SSL->error( "Failed to read PEM for DH from $f - wrong format?" );
	    my $rv = Net::SSLeay::CTX_set_tmp_dh( $ctx,$dh );
	    Net::SSLeay::DH_free( $dh );
	    $rv || return IO::Socket::SSL->error( "Failed to set DH from $f" );
	}
    }

    my $verify_callback = $verify_cb &&
	sub {
	    my ($ok, $ctx_store) = @_;
	    my ($cert, $error);
	    if ($ctx_store) {
		$cert = Net::SSLeay::X509_STORE_CTX_get_current_cert($ctx_store);
		$error = Net::SSLeay::X509_STORE_CTX_get_error($ctx_store);
		$cert &&= Net::SSLeay::X509_NAME_oneline(Net::SSLeay::X509_get_issuer_name($cert)).
		    Net::SSLeay::X509_NAME_oneline(Net::SSLeay::X509_get_subject_name($cert));
		$error &&= Net::SSLeay::ERR_error_string($error);
	    }
	    return $verify_cb->($ok, $ctx_store, $cert, $error);
	};

    Net::SSLeay::CTX_set_verify($ctx, $verify_mode, $verify_callback);

    $ctx_object = { context => $ctx };
    if ($arg_hash->{'SSL_session_cache_size'}) {
	if ($Net::SSLeay::VERSION < 1.26) {
	    return IO::Socket::SSL->error("Session caches not supported for Net::SSLeay < v1.26");
	} else {
	    $ctx_object->{'session_cache'} =
		IO::Socket::SSL::Session_Cache->new($arg_hash) || undef;
	}
    }

    return bless $ctx_object, $class;
}


sub session_cache {
    my $ctx = shift;
    my $cache = $ctx->{'session_cache'};
    return unless defined $cache;
    my ($addr, $port) = (shift, shift);
    my $key = "$addr:$port";
    my $session = shift;

    return (defined($session) ? $cache->add_session($key, $session)
			      : $cache->get_session($key));
}

sub has_session_cache {
    my $ctx = shift;
    return (defined $ctx->{'session_cache'});
}


sub DESTROY {
    my $self = shift;
    $self->{context} and Net::SSLeay::CTX_free($self->{context});
    delete(@{$self}{'context','session_cache'});
}


package IO::Socket::SSL::Session_Cache;
use strict;

sub new {
    my ($class, $arg_hash) = @_;
    my $cache = { _maxsize => $arg_hash->{'SSL_session_cache_size'}};
    return unless ($cache->{_maxsize} > 0);
    return bless $cache, $class;
}


sub get_session {
    my ($self, $key) = @_;
    my $session = $self->{$key} || return;
    return $session->{session} if ($self->{'_head'} eq $session);
    $session->{prev}->{next} = $session->{next};
    $session->{next}->{prev} = $session->{prev};
    $session->{next} = $self->{'_head'};
    $session->{prev} = $self->{'_head'}->{prev};
    $self->{'_head'}->{prev} = $self->{'_head'}->{prev}->{next} = $session;
    $self->{'_head'} = $session;
    return $session->{session};
}

sub add_session {
    my ($self, $key, $val) = @_;

    return if ($key eq '_maxsize' or $key eq '_head');

    if ((keys %$self) > $self->{'_maxsize'} + 1) {
	my $last = $self->{'_head'}->{prev};
	&Net::SSLeay::SESSION_free($last->{session});
	delete($self->{$last->{key}});
	$self->{'_head'}->{prev} = $self->{'_head'}->{prev}->{prev};
	delete($self->{'_head'}) if ($self->{'_maxsize'} == 1);
    }

    my $session = $self->{$key} = { session => $val, key => $key };

    if ($self->{'_head'}) {
	$session->{next} = $self->{'_head'};
	$session->{prev} = $self->{'_head'}->{prev};
	$self->{'_head'}->{prev}->{next} = $session;
	$self->{'_head'}->{prev} = $session;
    } else {
	$session->{next} = $session->{prev} = $session;
    }
    $self->{'_head'} = $session;
    return $session;
}

sub DESTROY {
    my $self = shift;
    delete(@{$self}{'_head','_maxsize'});
    foreach my $key (keys %$self) {
	Net::SSLeay::SESSION_free($self->{$key}->{session});
    }
}


1;


=head1 NAME

IO::Socket::SSL -- Nearly transparent SSL encapsulation for IO::Socket::INET.

=head1 SYNOPSIS

    use IO::Socket::SSL;

    my $client = IO::Socket::SSL->new("www.example.com:https");

    if ($client) {
	print $client "GET / HTTP/1.0\r\n\r\n";
	print <$client>;
	close $client;
    } else {
	warn "I encountered a problem: ",
	  IO::Socket::SSL::errstr();
    }


=head1 DESCRIPTION

This module is a true drop-in replacement for IO::Socket::INET that uses
SSL to encrypt data before it is transferred to a remote server or
client.  IO::Socket::SSL supports all the extra features that one needs
to write a full-featured SSL client or server application: multiple SSL contexts,
cipher selection, certificate verification, and SSL version selection.  As an
extra bonus, it works perfectly with mod_perl.

If you have never used SSL before, you should read the appendix labelled 'Using SSL'
before attempting to use this module.

If you have used this module before, read on, as versions 0.93 and above
have several changes from the previous IO::Socket::SSL versions (especially
see the note about return values).

If you are using non-blocking sockets read on, as version 0.98 added better
support for non-blocking.

=head1 METHODS

IO::Socket::SSL inherits its methods from IO::Socket::INET, overriding them
as necessary.  If there is an SSL error, the method or operation will return an
empty list (false in all contexts).  The methods that have changed from the
perspective of the user are re-documented here:

=over 4

=item B<new(...)>

Creates a new IO::Socket::SSL object.  You may use all the friendly options
that came bundled with IO::Socket::INET, plus (optionally) the ones that follow:

=over 2

=item SSL_version

Sets the version of the SSL protocol used to transmit data.  The default is SSLv2/3,
which auto-negotiates between SSLv2 and SSLv3.  You may specify 'SSLv2', 'SSLv3', or
'TLSv1' (case-insensitive) if you do not want this behavior.

=item SSL_cipher_list

If this option is set the cipher list for the connection will be set to the
given value, e.g. something like 'ALL:!LOW:!EXP:!ADH'. Look into the OpenSSL 
documentation (L<http://www.openssl.org/docs/apps/ciphers.html#CIPHER_STRINGS>)
for more details.
If this option is not used the openssl builtin default is used which is suitable
for most cases.

=item SSL_use_cert

If this is set, it forces IO::Socket::SSL to use a certificate and key, even if
you are setting up an SSL client.  If this is set to 0 (the default), then you will
only need a certificate and key if you are setting up a server.

=item SSL_key_file

If your RSA private key is not in default place (F<certs/server-key.pem> for servers,
F<certs/client-key.pem> for clients), then this is the option that you would use to
specify a different location.  Keys should be PEM formatted, and if they are
encrypted, you will be prompted to enter a password before the socket is formed
(unless you specified the SSL_passwd_cb option).

=item SSL_key

This is an EVP_PKEY* and can be used instead of SSL_key_file.
Useful if you don't have your key in a file but create it dynamically or get it from
a string (see openssl PEM_read_bio_PrivateKey etc for getting a EVP_PKEY* from
a string).

=item SSL_cert_file

If your SSL certificate is not in the default place (F<certs/server-cert.pem> for servers,
F<certs/client-cert.pem> for clients), then you should use this option to specify the
location of your certificate.  Note that a key and certificate are only required for an
SSL server, so you do not need to bother with these trifling options should you be
setting up an unauthenticated client.

=item SSL_cert

This is an X509* or an array of X509*.
The first X509* is the internal representation of the certificate while the following
ones are extra certificates. Useful if you create your certificate dynamically (like
in a SSL intercepting proxy) or get it from a string (see openssl PEM_read_bio_X509 etc
for getting a X509* from a string).

=item SSL_dh_file

If you want Diffie-Hellman key exchange you need to supply a suitable file here
or use the SSL_dh parameter. See dhparam command in openssl for more information.

=item SSL_dh

Like SSL_dh_file, but instead of giving a file you use a preloaded or generated DH*.

=item SSL_passwd_cb

If your private key is encrypted, you might not want the default password prompt from
Net::SSLeay.  This option takes a reference to a subroutine that should return the
password required to decrypt your private key.

=item SSL_ca_file

If you want to verify that the peer certificate has been signed by a reputable
certificate authority, then you should use this option to locate the file
containing the certificateZ<>(s) of the reputable certificate authorities if it is
not already in the file F<certs/my-ca.pem>.

=item SSL_ca_path

If you are unusually friendly with the OpenSSL documentation, you might have set
yourself up a directory containing several trusted certificates as separate files
as well as an index of the certificates.  If you want to use that directory for
validation purposes, and that directory is not F<ca/>, then use this option to
point IO::Socket::SSL to the right place to look.

=item SSL_verify_mode

This option sets the verification mode for the peer certificate.  The default
(0x00) does no authentication.  You may combine 0x01 (verify peer), 0x02 (fail
verification if no peer certificate exists; ignored for clients), and 0x04
(verify client once) to change the default.

=item SSL_verify_callback

If you want to verify certificates yourself, you can pass a sub reference along
with this parameter to do so.  When the callback is called, it will be passed:
1) a true/false value that indicates what OpenSSL thinks of the certificate,
2) a C-style memory address of the certificate store,
3) a string containing the certificate's issuer attributes and owner attributes, and
4) a string containing any errors encountered (0 if no errors).
The function should return 1 or 0, depending on whether it thinks the certificate
is valid or invalid.  The default is to let OpenSSL do all of the busy work.

=item SSL_check_crl

If you want to verify that the peer certificate has not been revoked by the
signing authority, set this value to true.  OpenSSL will search for the CRL
in your SSL_ca_path.  See the Net::SSLeay documentation for more details.
Note that this functionality appears to be broken with OpenSSL < v0.9.7b,
so its use with lower versions will result in an error.

=item SSL_reuse_ctx

If you have already set the above options (SSL_version through SSL_check_crl;
this does not include SSL_cipher_list yet) for a previous instance of
IO::Socket::SSL, then you can reuse the SSL context of that instance by passing
it as the value for the SSL_reuse_ctx parameter.  You may also create a
new instance of the IO::Socket::SSL::SSL_Context class, using any context options
that you desire without specifying connection options, and pass that here instead.

If you use this option, all other context-related options that you pass
in the same call to new() will be ignored unless the context supplied was invalid.
Note that, contrary to versions of IO::Socket::SSL below v0.90, a global SSL context
will not be implicitly used unless you use the set_default_context() function.

=item SSL_session_cache_size

If you make repeated connections to the same host/port and the SSL renegotiation time
is an issue, you can turn on client-side session caching with this option by specifying a
positive cache size.  For successive connections, pass the SSL_reuse_ctx option to
the new() calls (or use set_default_context()) to make use of the cached sessions.
The session cache size refers to the number of unique host/port pairs that can be
stored at one time; the oldest sessions in the cache will be removed if new ones are
added.  

=item SSL_error_trap

When using the accept() or connect() methods, it may be the case that the
actual socket connection works but the SSL negotiation fails, as in the case of
an HTTP client connecting to an HTTPS server.  Passing a subroutine ref attached
to this parameter allows you to gain control of the orphaned socket instead of having it
be closed forcibly.  The subroutine, if called, will be passed two parameters:
a reference to the socket on which the SSL negotiation failed and and the full
text of the error message.

=back

=item B<close(...)>

There are a number of nasty traps that lie in wait if you are not careful about using
close().  The first of these will bite you if you have been using shutdown() on your
sockets.  Since the SSL protocol mandates that a SSL "close notify" message be
sent before the socket is closed, a shutdown() that closes the socket's write channel
will cause the close() call to hang.  For a similar reason, if you try to close a
copy of a socket (as in a forking server) you will affect the original socket as well.
To get around these problems, call close with an object-oriented syntax
(e.g. $socket->close(SSL_no_shutdown => 1))
and one or more of the following parameters:

=over 2

=item SSL_no_shutdown

If set to a true value, this option will make close() not use the SSL_shutdown() call
on the socket in question so that the close operation can complete without problems
if you have used shutdown() or are working on a copy of a socket.

=item SSL_ctx_free

If you want to make sure that the SSL context of the socket is destroyed when
you close it, set this option to a true value.

=back

=item B<peek(...)>

This function has exactly the same syntax as sysread(), and performs nearly the same
task (reading data from the socket) but will not advance the read position so
that successive calls to peek() with the same arguments will return the same results.
This function requires OpenSSL 0.9.6a or later to work.


=item B<pending()>

This function will let you know how many bytes of data are immediately ready for reading
from the socket.  This is especially handy if you are doing reads on a blocking socket
or just want to know if new data has been sent over the socket.


=item B<get_cipher()>

Returns the string form of the cipher that the IO::Socket::SSL object is using.

=item B<dump_peer_certificate()>

Returns a parsable string with select fields from the peer SSL certificate.  This
method directly returns the result of the dump_peer_certificate() method of Net::SSLeay.

=item B<peer_certificate($field)>

If a peer certificate exists, this function can retrieve values from it.  Right now, the
only fields it can return are "authority" and "owner" (or "issuer" and "subject" if
you want to use OpenSSL names), corresponding to the certificate authority that signed the
peer certificate and the owner of the peer certificate.  This function returns a string
with all the information about the particular field in one parsable line.
If no field is given it returns the full certificate (x509).

=item B<errstr()>

Returns the last error (in string form) that occurred.  If you do not have a real
object to perform this method on, call IO::Socket::SSL::errstr() instead.

For read and write errors on non-blocking sockets, this method may include the string
C<SSL wants a read first!> or C<SSL wants a write first!> meaning that the other side
is expecting to read from or write to the socket and wants to be satisfied before you
get to do anything. But with version 0.98 you are better comparing the global exported 
variable $SSL_ERROR against the exported symbols SSL_WANT_READ and SSL_WANT_WRITE.

=item B<< IO::Socket::SSL->start_SSL($socket, ... ) >>

This will convert a glob reference or a socket that you provide to an IO::Socket::SSL
object.  You may also pass parameters to specify context or connection options as with
a call to new().  If you are using this function on an accept()ed socket, you must
set the parameter "SSL_server" to 1, i.e. IO::Socket::SSL->start_SSL($socket, SSL_server => 1).
If you have a class that inherits from IO::Socket::SSL and you want the $socket to be blessed
into your own class instead, use MyClass->start_SSL($socket) to achieve the desired effect.

Note that if start_SSL() fails in SSL negotiation, $socket will remain blessed in its 
original class.  For non-blocking sockets you better just upgrade the socket to 
IO::Socket::SSL and call accept_SSL or connect_SSL and the upgraded object. To
just upgrade the socket set B<SSL_startHandshake> explicitly to 0. If you call start_SSL
w/o this parameter it will revert to blocking behavior for accept_SSL and connect_SSL.

=item B<< IO::Socket::SSL->new_from_fd($fd, ...) >>

This will convert a socket identified via a file descriptor into an SSL socket.
Note that the argument list does not include a "MODE" argument; if you supply one,
it will be thoughtfully ignored (for compatibility with IO::Socket::INET).  Instead,
a mode of '+<' is assumed, and the file descriptor passed must be able to handle such
I/O because the initial SSL handshake requires bidirectional communication.

=item B<IO::Socket::SSL::set_default_context(...)>

You may use this to make IO::Socket::SSL automatically re-use a given context (unless
specifically overridden in a call to new()).  It accepts one argument, which should
be either an IO::Socket::SSL object or an IO::Socket::SSL::SSL_Context object.  See
the SSL_reuse_ctx option of new() for more details.  Note that this sets the default
context globally, so use with caution (esp. in mod_perl scripts).

=back

The following methods are unsupported (not to mention futile!) and IO::Socket::SSL
will emit a large CROAK() if you are silly enough to use them:

=over 4

=item truncate

=item stat

=item ungetc

=item setbuf

=item setvbuf

=item fdopen

=item send/recv

Note that send() and recv() cannot be reliably trapped by a tied filehandle (such as
that used by IO::Socket::SSL) and so may send unencrypted data over the socket.  Object-oriented
calls to these functions will fail, telling you to use the print/printf/syswrite
and read/sysread families instead.

=back


=head1 RETURN VALUES

A few changes have gone into IO::Socket::SSL v0.93 and later with respect to
return values.  The behavior on success remains unchanged, but for I<all> functions,
the return value on error is now an empty list.  Therefore, the return value will be
false in all contexts, but those who have been using the return values as arguments
to subroutines (like C<mysub(IO::Socket::SSL(...)->new, ...)>) may run into problems.
The moral of the story: I<always> check the return values of these functions before
using them in any way that you consider meaningful.


=head1 IPv6

Support for IPv6 with IO::Socket::SSL is expected to work, but is experimental, as
none of the author's machines use IPv6 and hence he cannot test IO::Socket::SSL with
them.  However, a few brave people have used it without incident, so if you wish to
make IO::Socket::SSL IPv6 aware, pass the 'inet6' option to IO::Socket::SSL when
calling it (i.e. C<use IO::Socket::SSL qw(inet6);>).  You will need IO::Socket::INET6
and Socket6 to use this option, and you will also need to write C<use Socket6;> before
using IO::Socket::SSL.  If you absolutely do not want to use this (or want a quick
change back to IPv4), pass the 'inet4' option instead.

Currently, there is no support for using IPv4 and IPv6 simultaneously in a single program, 
but it is planned for a future release.


=head1 DEBUGGING

If you are having problems using IO::Socket::SSL despite the fact that can recite backwards
the section of this documentation labelled 'Using SSL', you should try enabling debugging.  To
specify the debug level, pass 'debug#' (where # is a number from 0 to 4) to IO::Socket::SSL
when calling it:

=over 4

=item use IO::Socket::SSL qw(debug0);

#No debugging (default).

=item use IO::Socket::SSL qw(debug1);

#Only print out errors.

=item use IO::Socket::SSL qw(debug2);

#Print out errors and cipher negotiation.

=item use IO::Socket::SSL qw(debug3);

#Print out progress, ciphers, and errors.

=item use IO::Socket::SSL qw(debug4);

#Print out everything, including data.

=back

You can also set $IO::Socket::SSL::DEBUG to 0-4, but that's a bit of a mouthful,
isn't it?

=head1 EXAMPLES

See the 'example' directory.

=head1 BUGS

IO::Socket::SSL is not threadsafe.
This is because IO::Socket::SSL is based on Net::SSLeay which 
uses a global object to access some of the API of openssl
and is therefore not threadsafe.

=head1 LIMITATIONS

IO::Socket::SSL uses Net::SSLeay as the shiny interface to OpenSSL, which is
the shiny interface to the ugliness of SSL.  As a result, you will need both Net::SSLeay
and OpenSSL on your computer before using this module.

If you have Scalar::Util (standard with Perl 5.8.0 and above) or WeakRef, IO::Socket::SSL
sockets will auto-close when they go out of scope, just like IO::Socket::INET sockets.  If
you do not have one of these modules, then IO::Socket::SSL sockets will stay open until the
program ends or you explicitly close them.  This is due to the fact that a circular reference
is required to make IO::Socket::SSL sockets act simultaneously like objects and glob references.

=head1 DEPRECATIONS

The following functions are deprecated and are only retained for compatibility:

=over 2

=item context_init()

(use the SSL_reuse_ctx option if you want to re-use a context)


=item socketToSSL() and socket_to_SSL()

(use IO::Socket::SSL->start_SSL() instead)


=item get_peer_certificate() and friends

(use the peer_certificate() function instead)


=back

The following classes have been removed:

=over 2

=item SSL_SSL

(not that you should have been directly accessing this anyway):

=item X509_Certificate

(but get_peer_certificate() will still Do The Right Thing)

=back

=head1 SEE ALSO

IO::Socket::INET, IO::Socket::INET6, Net::SSLeay.

=head1 AUTHORS

Steffen Ullrich, <steffen at genua.de> is the current maintainer.

Peter Behroozi, <behrooz at fas.harvard.edu> (Note the lack of an "i" at the end of "behrooz")

Marko Asplund, <marko.asplund at kronodoc.fi>, was the original author of IO::Socket::SSL.

Patches incorporated from various people, see file Changes.

=head1 COPYRIGHT

Working support for non-blocking was added by Steffen Ullrich.

The rewrite of this module is Copyright (C) 2002-2005 Peter Behroozi.

The original versions of this module are Copyright (C) 1999-2002 Marko Asplund.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


=head1 Appendix: Using SSL

If you are unfamiliar with the way OpenSSL works, good references may be found in
both the book "Network Security with OpenSSL" (Oreilly & Assoc.) and the web site
L<http://www.tldp.org/HOWTO/SSL-Certificates-HOWTO/>.  Read on for a quick overview.

=head2 The Long of It (Detail)

The usual reason for using SSL is to keep your data safe.  This means that not only
do you have to encrypt the data while it is being transported over a network, but
you also have to make sure that the right person gets the data.  To accomplish this
with SSL, you have to use certificates.  A certificate closely resembles a
Government-issued ID (at least in places where you can trust them).  The ID contains some sort of
identifying information such as a name and address, and is usually stamped with a seal
of Government Approval.  Theoretically, this means that you may trust the information on
the card and do business with the owner of the card.  The same ideas apply to SSL certificates,
which have some identifying information and are "stamped" [most people refer to this as
I<signing> instead] by someone (a Certificate Authority) who you trust will adequately
verify the identifying information.  In this case, because of some clever number theory,
it is extremely difficult to falsify the stamping process.  Another useful consequence
of number theory is that the certificate is linked to the encryption process, so you may
encrypt data (using information on the certificate) that only the certificate owner can
decrypt.

What does this mean for you?  It means that at least one person in the party has to
have an ID to get drinks :-).  Seriously, it means that one of the people communicating
has to have a certificate to ensure that your data is safe.  For client/server
interactions, the server must B<always> have a certificate.  If the server wants to
verify that the client is safe, then the client must also have a personal certificate.
To verify that a certificate is safe, one compares the stamped "seal" [commonly called
an I<encrypted digest/hash/signature>] on the certificate with the official "seal" of
the Certificate Authority to make sure that they are the same.  To do this, you will
need the [unfortunately named] certificate of the Certificate Authority.  With all these
in hand, you can set up a SSL connection and be reasonably confident that no-one is
reading your data.

=head2 The Short of It (Summary)

For servers, you will need to generate a cryptographic private key and a certificate
request.  You will need to send the certificate request to a Certificate Authority to
get a real certificate back, after which you can start serving people.  For clients,
you will not need anything unless the server wants validation, in which case you will
also need a private key and a real certificate.  For more information about how to
get these, see L<http://www.modssl.org/docs/2.8/ssl_faq.html#ToC24>.

=cut
