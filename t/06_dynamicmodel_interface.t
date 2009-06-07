use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 2;

BEGIN { use_ok('ModelsFromConfigInterfaceApp'); }

my $config = ModelsFromConfigInterfaceApp->config;
delete $config->{'CatalystX::DynamicComponent::ModelToControllerReflector'};

is_deeply($config, {
    name => 'ModelsFromConfigInterfaceApp',
    'Model::One' => {
        class => 'SomeModelClass',
        interface_roles => [qw/ SomeModelClassInterface /],
    },
}, 'Config is not munged');

