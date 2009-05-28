use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 6;
use Test::Exception;

use SomeModelClass;
my $i = SomeModelClass->new;

throws_ok { $i->say_hello(); } qr/Validation failed/;
throws_ok { $i->say_hello({}); } qr/Validation failed/;
throws_ok { $i->say_hello({name => 'Fred'}); } qr/Validation failed/;
my $r;
lives_ok { $r = $i->say_hello({type => 'say_hello', name => 'Fred'}); };
ok $r;
is_deeply($r, { type => 'say_hello_response', body => "Hello Fred" });

