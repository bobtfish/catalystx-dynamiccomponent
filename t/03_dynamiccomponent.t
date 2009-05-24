use strict;
use warnings;

use Test::More tests => 10;
use Test::Exception;

use Moose ();
BEGIN { use_ok('CatalystX::DynamicComponent') }

my $testapp_counter = 0;
sub generate_testapp {
    my $role_options = shift || {};
    my $meta = Moose->init_meta( for_class => "TestApp" . $testapp_counter++ );
    $meta->superclasses('Catalyst');
    Moose::Util::apply_all_roles($meta, 'CatalystX::DynamicComponent', $role_options);
    $meta->name->setup;
    return $meta;
}

throws_ok { generate_testapp(); }
    qr/name\) is required/, 'name is required';

{
    my $app_meta = generate_testapp({ name => 'dynamic_component_method' });
    my $app = $app_meta->name;
    ok $app->can('dynamic_component_method'), 'dynamic component method added';
    $app->dynamic_component_method( $app . "::Model::Foo", {} );
    my $foo = $app->model('Foo');
    ok $foo, 'Have added Foo component';
    isa_ok($foo, 'Catalyst::Component');
}

{
    my $COMPONENT = sub { return bless {}, 'TestClass' };
    my $app_meta = generate_testapp({
        name => 'dynamic_component_method',
        COMPONENT => $COMPONENT,
    });
    my $app = $app_meta->name;
    ok $app->can('dynamic_component_method'), 'dynamic component method added';
    $app->dynamic_component_method( $app . "::Model::Foo", {} );
    my $foo = $app->model('Foo');
    ok $foo, 'Have added Foo component';
    isa_ok($foo, 'TestClass', 'COMPONENT method returned totally different class');
    my $name = $app . "::Model::Foo";
    isa_ok(bless({}, $name), 'Catalyst::Component', 'Underlying $app::Model::Foo is a C::C');
    is($name->can('COMPONENT'), $COMPONENT, 'Supplied COMPONENT method is on $app::Model::Foo');
}


