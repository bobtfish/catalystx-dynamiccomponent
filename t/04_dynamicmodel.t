use strict;
use warnings;
use Test::More tests => 6;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use DynamicAppDemo;

# Naughty, should make an app instance.
my $model = DynamicAppDemo->model('One');

ok $model;
isa_ok $model, 'SomeModelClass';
is_deeply $model->say_hello({name => 'world'}), { type => 'say_hello_response', body => 'Hello world' };

ok(DynamicAppDemo->model('Two'), 'Have model Two');

ok(!DynamicAppDemo->model('Three'), 'No model Three');

ok(!DynamicAppDemo->model('Four'), 'No model Four');

