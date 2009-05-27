use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 3;

BEGIN { use_ok('ModelsFromConfigInterfaceApp'); }

my $controller = ModelsFromConfigInterfaceApp->controller('One');
ok $controller, 'Generated a controller';

my $action = $controller->action_for('say_hello');
ok $action, 'Got action reflected from model';

# Actions we generate are still totally frigging useless, so lets not test
# that here yet.

