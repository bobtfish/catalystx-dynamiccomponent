package TestComplexApp;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Catalyst qw/
    +CatalystX::DynamicComponent::ModelsFromConfig
    +CatalystX::DynamicComponent::ModelToControllerReflector
/;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config( 
    name => 'TestComplexApp',
    'CatalystX::DynamicComponent::ModelsFromConfig' => {
        include => 'PaymentProvider::',
        roles => 'TestComplexApp::ProfileModelLoader',
        methods => {
            COMPONENT => undef, # Remove custom COMPONENT method as
                                # we're doing our own thing with
                                # InstancePerContext
        },
    },
    'Model::PaymentProvider::Datacash' => {
        class => 'PaymentProvider::Datacash',
    },
    'Model::PaymentProvider::Cybersource' => {
        class => 'PaymentProvider::Cybersource',
    },
    'Model::PaymentProvider::Null' => {
        class => 'PaymentProvider::Null',
    },
);

# Ensure to load the model class early and so fail early..
sub _setup_dynamic_model_config {
    my ($app, $model_name, $config) = @_;
    
    die("Config for $model_name does not have a ->{class} key, fatal!\n")
        unless $config->{class};

    Class::MOP::load_class($config->{class});

    return $config;
}

__PACKAGE__->setup();

1;

