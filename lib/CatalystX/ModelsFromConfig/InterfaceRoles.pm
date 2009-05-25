package # Hide from PAUSE
    CatalystX::ModelsFromConfig::InterfaceRoles::COMPONENT;
use Moose::Role;
use Moose::Util qw/does_role/;
use namespace::autoclean;

around 'COMPONENT' => sub {
    my ($orig, $component_class_name, $app, $args) = @_;

    my $interface_roles = delete $args->{interface_roles};
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

package CatalystX::ModelsFromConfig::InterfaceRoles;
use Moose::Role;
use Catalyst::Model::Adaptor ();
use namespace::autoclean;

with 'CatalystX::ModelsFromConfig';

around '_setup_dynamic_model' => sub {
    my ($orig, $app, $class_name, $config, @args) = @_;
    my @roles = @{ delete($config->{roles}) || [] };
    push(@roles, 'CatalystX::ModelsFromConfig::InterfaceRoles::COMPONENT');
    $config->{roles} = \@roles;
    $app->$orig($class_name, $config, @args);
};

1;

