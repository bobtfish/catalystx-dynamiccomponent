use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Moose::Util qw/does_role/;

use Test::More tests => 2;

use DynamicAppDemo;

# Naughty, should make an app instance.
my $controller = DynamicAppDemo->controller('One');

ok $controller;
ok ! $controller->action_for('get_reflected_action_methods'),
    'not leaking actions';

