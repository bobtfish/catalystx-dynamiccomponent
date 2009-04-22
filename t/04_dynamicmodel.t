use strict;
use warnings;
use Test::More tests => 3;

use DynamicAppDemo;

# Naughty, should make an app instance.
my $model = DynamicAppDemo->model('One');

ok $model;
isa_ok $model, 'SomeModelClass';
is $model->say_hello('world'), 'Hello world';

