package CatalystX::ModelsFromConfig;
use Moose::Role;
use Catalyst::Model::Adaptor ();

requires qw/
    config
    setup_components
    setup_component
/;

# Note method reaming - allows user to modify my setup_dynamic_component without being
#                       forced to do it globally.
with 'CatalystX::DynamicComponent' 
    => { alias => { _setup_dynamic_component => '_setup_dynamic_model' } };

after 'setup_components' => sub { shift->_setup_dynamic_models(@_); };

sub _setup_dynamic_models {
    my ($app) = @_;
    
    my $app_name = blessed($app) || $app;
    my $model_prefix = 'Model::';

    my $config = $app->config || {};
    
    foreach my $model_name ( grep { /^$model_prefix/ } keys %$config ) {
        my $model_class_name = $app_name . '::' . $model_name;
        
        $app->_setup_dynamic_model( $model_class_name, $config->{$model_name}, 
        sub {
            my ($component_class_name, $app, $args) = @_;

            my $class = delete $args->{class};
            Class::MOP::load_class($class);

            $class->new($args);
        });
    }
}

1;

