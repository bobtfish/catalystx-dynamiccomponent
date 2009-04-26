package CatalystX::DynamicComponent;
use MooseX::Role::Parameterized;
use namespace::autoclean;

parameter 'name' => (
    isa => 'Str',
    required => 1,
);

parameter 'pre_immutable_hook' => (
    isa => 'Str',
    predicate => 'has_pre_immutable_hook',
);

role {
    my $p = shift;
    my $name = $p->name;
    my $pre_immutable_hook = $p->pre_immutable_hook if $p->has_pre_immutable_hook;
    method $name => sub {
        my ($app, $name, $config, $component_method) = @_;

        my $appclass = blessed($app) || $app;
        my $type = $name;
        $type =~ s/^${appclass}:://; # FIXME - I think there is shit in C::Utils to do this.
        $type =~ s/::.*$//;

        my $meta = Moose->init_meta( for_class => $name );
        $meta->superclasses('Catalyst::' . $type);
        $meta->add_method( COMPONENT => $component_method );
        $app->$pre_immutable_hook($meta) if $pre_immutable_hook;
        $meta->make_immutable;

        my $instance = $app->setup_component($name);
        $app->components->{ $name } = $instance;
    };
};

1;

