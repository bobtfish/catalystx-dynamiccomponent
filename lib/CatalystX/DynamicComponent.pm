package CatalystX::DynamicComponent;
use Moose::Role;
use namespace::clean -excpept => 'meta';

sub _setup_dynamic_component {
    my ($app, $name, $config) = @_;

    my $appclass = blessed($app) || $app;
    my $type = $name;
    $type =~ s/^${appclass}:://; # FIXME - I think there is shit in C::Utils to do this.
    $type =~ s/::.*$//;

    my $meta = Moose->init_meta( for_class => $name );
    $meta->superclasses('Catalyst::' . $type);

    $meta->add_method(

      COMPONENT
            => sub {
        my ($component_class_name, $app, $args) = @_;

        my $class = delete $args->{class};
        Class::MOP::load_class($class);

        $class->new($args);
    });

    $meta->make_immutable;

    my $instance = $app->setup_component($name);
    $app->components->{ $name } = $instance;
}

1;

