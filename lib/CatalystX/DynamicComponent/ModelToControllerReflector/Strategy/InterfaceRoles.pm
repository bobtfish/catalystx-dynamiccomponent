package CatalystX::DynamicComponent::ModelToControllerReflector::Strategy::InterfaceRoles;
use Moose;
use MooseX::Types::Moose qw/HashRef/;
use Moose::Autobox;
use List::MoreUtils qw/uniq/;
use namespace::autoclean;

with 'CatalystX::DynamicComponent::ModelToControllerReflector::Strategy';

sub get_reflected_method_list {;
    my ($self, $app, $model_name) = @_;
    my $model_config = exists $app->config->{$model_name} ? $app->config->{$model_name} : {};
    my $my_config = exists $app->config->{'CatalystX::DynamicComponent::ModelToControllerReflector'}
        ? $app->config->{'CatalystX::DynamicComponent::ModelToControllerReflector'} : {};
    my $interface_roles = [ uniq( map { (defined $_ && exists $_->{interface_roles}) ? $_->{interface_roles}->flatten : () } $model_config, $my_config ) ];

    map { $_->meta->get_required_method_list } @$interface_roles;
}

__PACKAGE__->meta->make_immutable;

