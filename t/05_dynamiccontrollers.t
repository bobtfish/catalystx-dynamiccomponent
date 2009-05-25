use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Moose::Util qw/does_role/;

use Test::More tests => 6;

use DynamicAppDemo;

# Naughty, should make an app instance.
my $controller = DynamicAppDemo->controller('One');

ok $controller;
isa_ok $controller, 'DynamicAppDemo::ControllerBase';
ok $controller->can('method_from_controller_role'), 'Role appears applied';

ok ! $controller->action_for('get_reflected_action_methods'),
    'not leaking actions';

ok ! $controller->action_for('method_from_controller_role'),
    'not leaking actions';

ok  $controller->action_for('say_hello'),
    'Am finding generated actions';

