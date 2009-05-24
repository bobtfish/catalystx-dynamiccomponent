use strict;
use warnings;

use Test::More tests => 26;
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
        methods => {
            COMPONENT => $COMPONENT,
        },
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
{
    package My::Other::Superclass;
    use Moose;
    __PACKAGE__->meta->make_immutable;
}
{
    package My::Model;
    use Moose;
    extends qw/Catalyst::Model/;
    __PACKAGE__->meta->make_immutable;
}
{
    package My::Role;
    use Moose::Role;
    sub _some_method_from_role {}
}
{
    package My::Other::Role;
    use Moose::Role;
    sub _some_method_from_other_role {}
}
my %generator_config = (
    name => 'dynamic_component_method',
    roles => [qw/My::Other::Role/],
    superclasses => ['My::Other::Superclass'],
    methods => {
        my_other_injected_method => sub {},
    },
);
my $extra_config = {
    superclasses => ['My::Model'],
    roles => ['My::Role'],
    methods => {
        my_injected_method => sub { 'quuux' },
    }
};
{
    # Do not specify any resolve strategies, so get defaults:
    # methods - merge
    # superclasses - replace
    # roles - merge
    my $app_meta = generate_testapp({
        %generator_config,
    });
    my $app = $app_meta->name;
    $app->dynamic_component_method( $app . "::Model::Foo", $extra_config );
    my $model = $app->model('Foo');
    isa_ok($model, 'My::Model', 'Correct superclass');
    ok(!$model->isa('My::Other::Superclass'),
        'superclass in extra config replaces by default');

    ok $model->can('_some_method_from_role'), 'Has had role applied';
    ok !My::Model->can('_some_method_from_role'), 'Role applied at right place';
    
    ok $model->can('_some_method_from_other_role'),
        'Role application merges by default';

    ok $model->can('my_injected_method'), 'Injected method there as expected';
    is $model->my_injected_method, 'quuux', 'Injected method returns correct val';

    ok $model->can('my_other_injected_method'),
        'Injected methods merged by default';
}
{
    # Specify resolve strategies, totally opposite the defaults:
    my $app_meta = generate_testapp({
        %generator_config,
        roles_resolve_strategy => 'replace',
        superclasses_resolve_strategy => 'merge',
        methods_resolve_strategy => 'replace',
    });
    my $app = $app_meta->name;
    $app->dynamic_component_method( $app . "::Model::Foo", $extra_config );
    my $model = $app->model('Foo');
    isa_ok($model, 'My::Model', 'Correct superclass');
    isa_ok($model, 'My::Other::Superclass',
        'superclasses merged');

    ok $model->can('_some_method_from_role'), 'Has had role applied';
    ok !My::Model->can('_some_method_from_role'), 'Role applied at right place';
    
    ok !$model->can('_some_other_method_from_role'),
        'Role application merges replaces when configured';

    ok $model->can('my_injected_method'), 'Injected method there as expected';
    is $model->my_injected_method, 'quuux', 'Injected method returns correct val';

    ok !$model->can('my_other_injected_method'),
        'Injected methods replaced';
}

