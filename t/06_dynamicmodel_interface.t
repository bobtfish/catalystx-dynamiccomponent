use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Data::Dumper;

use Test::More tests => 2;

BEGIN { use_ok('ModelsFromConfigInterfaceApp'); }

my $config = ModelsFromConfigInterfaceApp->config;

my $expected = {
    name => 'ModelsFromConfigInterfaceApp',
    'Model::One' => {
        class => 'SomeModelClass',
        interface_roles => [qw/ SomeModelClassInterface /],
    },
};

is_deeply($config, $expected, 'Config is not munged')
    or warn Dumper([$config, $expected]);

