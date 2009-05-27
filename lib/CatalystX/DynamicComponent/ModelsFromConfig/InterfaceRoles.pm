package # Hide from PAUSE
    CatalystX::DynamicComponent::ModelsFromConfig::InterfaceRoles::COMPONENT;
use Moose::Role;
use Moose::Util qw/does_role/;
use namespace::autoclean;

around 'COMPONENT' => sub {
    my ($orig, $component_class_name, $app, $args) = @_;

    my $interface_roles = $args->{interface_roles};
    confess("No interface_roles configuration specified for $component_class_name")
        unless $interface_roles && ref($interface_roles) eq 'ARRAY'
            && scalar(@$interface_roles);

    my $component = $component_class_name->$orig($app, $args);

    foreach my $role_name (@$interface_roles) {
        confess("$component_class_name generated an instance $component which does not perform the required $role_name role")
            unless does_role($component, $role_name);
    }

    return $component;
};

package CatalystX::DynamicComponent::ModelsFromConfig::InterfaceRoles;
use Moose::Role;
use namespace::autoclean;

with 'CatalystX::DynamicComponent::ModelsFromConfig';

around '_setup_dynamic_model' => sub {
    my ($orig, $app, $class_name, $config, @args) = @_;
    my @roles = @{ delete($config->{roles}) || [] };
    push(@roles, 'CatalystX::DynamicComponent::ModelsFromConfig::InterfaceRoles::COMPONENT');
    local $config->{roles} = \@roles;
    $app->$orig($class_name, $config, @args);
};

1;

__END__

=head1 NAME

CatalystX::DynamicComponent::ModelsFromConfig::InterfaceRoles - Generate simple L<Catalyst::Model::Adaptor> like models from application config, enforcing roles on the model classes.

=head1 SYNOPSIS

    package MyApp;
    use Moose;
    use namespace::autoclean;
    use Catalyst qw/
        +CatalystX::DynamicComponent::ModelsFromConfig::InterfaceRoles
    /;
    __PACKAGE__->config(
        name => __PACKAGE__,
        'CatalystX::DynamicComponent::ModelsFromConfig' => {
            include => 'One^',
        },
        'Model::One' => {
            class => 'SomeClass', # Name of class to load and construct
            other => 'config',    # Constructor passed other parameters
            interface_roles => [qw/ My::Role /], # Your app explodes if SomeClass doesn't do My::Role
        },
        ...
    );
    __PACKAGE__->setup;


=head1 DESCRIPTION

FIXME

=head1 LINKS

L<CatalystX::DynamicComponent::ModelsFromConfig>, L<CatalystX::DynamicComponent>, L<Catalyst>.

=head1 BUGS

Probably plenty, test suite certainly isn't comprehensive.. Patches welcome.

=head1 AUTHOR

Tomas Doran (t0m) <bobtfish@bobtfish.net>

=head1 LICENSE

This code is copyright (c) 2009 Tomas Doran. This code is licensed on the same terms as perl
itself.

=cut

