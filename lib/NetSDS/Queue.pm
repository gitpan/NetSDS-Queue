#===============================================================================
#
#         FILE:  Queue.pm
#
#  DESCRIPTION:  NetSDS Queue API
#
#       AUTHOR:  Michael Bochkaryov (Rattler), <misha@rattler.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  12.07.2009 11:41:24 UTC
#     REVISION:  $Id$
#===============================================================================

=head1 NAME

NetSDS::Queue - simple API to MemcacheQ powered queue

=head1 SYNOPSIS

	use NetSDS::Queue;
	use Data::Dumper;

	my $q = NetSDS::Queue->new( server => '10.0.0.5:18181' );

	# Push messages to queue
	$q->push('myq', { id => 1, text => 'one'});
	$q->push('myq', { id => 2, text => 'two'});
	$q->push('myq', { id => 3, text => 'three'});

	# Fetch messages from queue
	while ( my $data = $q->pull('myq') ) {
		print Dumper($data);
	}

=head1 DESCRIPTION

C<NetSDS::Queue> module provides simple API to NetSDS queue.

Low level messaging is based on fast and reliable MemcacheQ server.
It use BerkeleyDB for persistance and Memchache protocol over TCP
or Unix sockets.

Every message is converted to JSON and then stored as Base64 string.

=cut

package NetSDS::Queue;

use 5.8.0;
use strict;
use warnings;

use Cache::Memcached::Fast;
use NetSDS::Util::Convert;
use JSON;

use base qw(NetSDS::Class::Abstract);

use version; our $VERSION = "0.030";
our @EXPORT_OK = qw();

#===============================================================================
#

=head1 CLASS API

=over

=item B<new(%params)> - class constructor

The following parameters accepted:

* server - address to MemcacheQ queue server (host:port)

	my $queue = NetSDS::Queue->new(server => '192.168.0.1:12345');

Default server address is 127.0.0.1:22201

=cut

#-----------------------------------------------------------------------
sub new {

	my ( $class, %params ) = @_;

	my $this = $class->SUPER::new();

	# Set server (default is 127.0.0.1:22201)
	my $server = '127.0.0.1:22201';
	if ( $params{'server'} ) {
		$server = $params{'server'};
	}

	# Initialize memcacheq handler
	$this->{handler} = Cache::Memcached::Fast->new(
		{
			servers         => [$server],
			connect_timeout => 5,
		}
	);

	# Create accessors
	$this->mk_accessors('handler');

	if ( $this->handler ) {
		return $this;
	} else {
		return undef;
	}

} ## end sub new

#***********************************************************************

=item B<push($queue, $data)> - push message to queue

	$queue->push('msgq', $my_data);

=cut

#-----------------------------------------------------------------------

sub push {

	my ( $this, $queue, $data ) = @_;

	return $this->handler->set( $queue, _encode($data) );

}

#***********************************************************************

=item B<pull($queue)> - fetch message from queue

	my $data = $queue->pull('msgq');

=cut

#-----------------------------------------------------------------------

sub pull {

	my ( $this, $queue ) = @_;

	return _decode( $this->handler->get($queue) );

}

sub _encode {

	my ($struct) = @_;
	return conv_str_base64( encode_json($struct) );
}

sub _decode {

	my ($string) = @_;

	if ($string) {
		return decode_json( conv_base64_str($string) );
	} else {
		return undef;
	}
}

1;

__END__

=back

=head1 EXAMPLES

See files in C<samples> catalog.

=head1 BUGS

Unknown yet

=head1 SEE ALSO

http://memcachedb.org/memcacheq/ - MemcacheQ server
http://openhack.ru/Cache-Memcached-Fast - Perl XS API to Memcached servers

=head1 TODO

None

=head1 AUTHOR

Michael Bochkaryov <misha@rattler.kiev.ua>

=cut


