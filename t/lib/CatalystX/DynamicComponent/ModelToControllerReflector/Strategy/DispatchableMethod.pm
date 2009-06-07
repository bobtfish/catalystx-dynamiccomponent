package CatalystX::DynamicComponent::ModelToControllerReflector::Strategy::DispatchableMethod;
use Moose;
use MooseX::Types::Moose qw/HashRef/;
use Moose::Autobox;
use List::MoreUtils qw/uniq/;
use namespace::autoclean;

with 'CatalystX::DynamicComponent::ModelToControllerReflector::Strategy';

sub get_reflected_method_list {;
    my ($self, $app, $model_name, $model) = @_;
    my $model_methods = $model->meta->get_method_map;
    grep { does_role($model_methods->{$_}, 'CatalystX::ControllerGeneratingModel::DispatchableMethod') } keys %$model_methods;
}

__PACKAGE__->meta->make_immutable;

