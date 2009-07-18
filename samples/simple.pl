#!/usr/bin/env perl 

use 5.8.0;
use strict;
use warnings;

use NetSDS::Util::Convert;
use NetSDS::Util::String;

use NetSDS::Queue;
use Data::Dumper;

my $q = NetSDS::Queue->new();

my $data = {
	from => '380671112233',
	to => '1234',
	text => 'Test message',
};

$q->push('test_queue', $data);


my $res = $q->pull('test_queue');

print Dumper($res);

1;
