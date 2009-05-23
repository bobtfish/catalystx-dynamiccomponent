package CatalystX::DynamicComponent;
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw/Str CodeRef ArrayRef/;
use namespace::autoclean;

our $VERSION = 0.000001;

parameter 'name' => (
    isa => Str,
    required => 1,
);

parameter 'pre_immutable_hook' => (
    isa => Str,
    predicate => 'has_pre_immutable_hook',
);

parameter 'COMPONENT' => (
    isa => CodeRef,
    predicate => 'has_custom_component_method',
);

role {
    my $p = shift;
    my $name = $p->name;
    my $pre_immutable_hook = $p->pre_immutable_hook;

    method $name => sub {
        my ($app, $name, $config, $methods) = @_;

        my $appclass = blessed($app) || $app;
        my $type = $name;
        $type =~ s/^${appclass}:://; # FIXME - I think there is shit in C::Utils to do this.
        $type =~ s/::.*$//;

        my $meta = Moose->init_meta( for_class => $name );
        my @superclasses = @{ $config->{superclasses} || [] };
        push(@superclasses, 'Catalyst::' . $type) unless @superclasses;
        $meta->superclasses(@superclasses);

        Moose::Util::apply_all_roles( $meta, @{ $config->{roles}||[] } ) if @{ $config->{roles}||[] };

        if ($p->has_custom_component_method) {
            $meta->add_method(COMPONENT => $p->COMPONENT);
        }

        $app->$pre_immutable_hook($meta) if $p->has_pre_immutable_hook;

        $methods ||= {};
        foreach my $name (keys %$methods) {
            $meta->add_method($name => $methods->{$name});
        }
        $meta->make_immutable;

        my $instance = $app->setup_component($name);
        $app->components->{ $name } = $instance;
    };
};

1;

