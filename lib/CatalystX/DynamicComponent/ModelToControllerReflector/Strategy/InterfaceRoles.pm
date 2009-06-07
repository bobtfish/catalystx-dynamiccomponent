package CatalystX::DynamicComponent::ModelToControllerReflector::Strategy::InterfaceRoles;
use Moose;
use MooseX::Types::Moose qw/HashRef/;
use Moose::Autobox;
use List::MoreUtils qw/uniq/;
use namespace::autoclean;

with 'CatalystX::DynamicComponent::ModelToControllerReflector::Strategy';

sub get_reflected_method_list {;
    my ($self, $app, $model_meta) = @_;
    my $model_name = $model_meta->name;
    my $interface_roles = [ uniq( map { exists $_->{interface_roles} ? $_->{interface_roles}->flatten : () } $app->config->{$model_name}, $app->config->{'CatalystX::DynamicComponent::ModelToControllerReflector'} ) ];

    map { $_->meta->get_required_method_list } @$interface_roles;
}

__PACKAGE__->meta->make_immutable;

