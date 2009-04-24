package CatalystX::DynamicComponent;
use Moose::Role;
use namespace::autoclean;

sub _setup_dynamic_component {
    my ($app, $name, $config, $component_method) = @_;

    my $appclass = blessed($app) || $app;
    my $type = $name;
    $type =~ s/^${appclass}:://; # FIXME - I think there is shit in C::Utils to do this.
    $type =~ s/::.*$//;

    my $meta = Moose->init_meta( for_class => $name );
    $meta->superclasses('Catalyst::' . $type);

    $meta->add_method( COMPONENT => $component_method );

    $meta->make_immutable;

    my $instance = $app->setup_component($name);
    $app->components->{ $name } = $instance;
}

1;

