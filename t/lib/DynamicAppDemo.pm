package DynamicAppDemo;
use Moose;
use Catalyst::Runtime '5.80002';

use Catalyst qw/
    +CatalystX::DynamicComponent::ModelsFromConfig
    +CatalystX::DynamicComponent::ModelToControllerReflector
/;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'DynamicAppDemo',
    'Controller::One' => {
        superclasses => [qw/DynamicAppDemo::ControllerBase/],
        roles      => [qw/DynamicAppDemo::ControllerRole/],
    },
    'CatalystX::DynamicComponent::ModelToControllerReflector' => {
        interface_roles => 'SomeModelClassInterface',
    },
    'CatalystX::DynamicComponent::ModelsFromConfig' => {
        include => 'One|Two|Four',
        exclude => 'Four',
    },
    'Model::One' => {
        class => 'SomeModelClass',
    },
    'Model::Two' => {
        class => 'SomeModelClass',
    },
    'Model::Three' => {
        class => 'SomeModelClass',
    },
    'Model::Four' => {
        class => 'SomeModelClass',
    },
);

__PACKAGE__->setup();

__PACKAGE__->meta->make_immutable;

