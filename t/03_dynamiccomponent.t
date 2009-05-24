use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use Moose ();
BEGIN { use_ok('CatalystX::DynamicComponent') }

my $testapp_counter = 0;
sub generate_testapp {
    my $role_options = shift || {};
    my $meta = Moose->init_meta( for_class => "TestApp" . $testapp_counter++ );
    $meta->superclasses('Catalyst');
    Moose::Util::apply_all_roles($meta, 'CatalystX::DynamicComponent', $role_options);
    return $meta;
}

throws_ok { generate_testapp(); }
    qr/name\) is required/, 'name is required';

{
    my $app_meta = generate_testapp({ name => 'dynamic_component_method' });
    my $app = $app_meta->name;
    ok $app->can('dynamic_component_method'), 'dynamic component method added';

}

