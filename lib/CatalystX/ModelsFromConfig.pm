package CatalystX::ModelsFromConfig;
use Moose::Role;
use Catalyst::Model::Adaptor ();

requires qw/
    config
    setup_components
    setup_component
/;

after 'setup_components' => sub { shift->_setup_dynamic_models(@_); };

sub _setup_dynamic_models {
    my ($app) = @_;
    
    my $app_name = blessed($app) || $app;
    my $model_prefix = 'Model::';

    my $model_hash = $app->config || {};
    
    foreach my $model_name ( grep { /^$model_prefix/ } keys %$model_hash ) {
        my $model_class_name = $app_name . '::' . $model_name;
        $app->_setup_dynamic_model( $model_class_name, $model_hash->{$model_name} );
    }
}

sub _setup_dynamic_model {
    my ($app, $name, $config) = @_;
    
    my $meta = Moose->init_meta( for_class => $name );
    $meta->superclasses('Catalyst::Model');
    
    $meta->add_method( 

      COMPONENT 
            => sub {
        my ($model_class_name, $app, $args) = @_;
        
        my $class = delete $args->{class};
        Class::MOP::load_class($class);
        
        $class->new($args);
    });

    $meta->make_immutable;

    my $instance = $app->setup_component($name);
    $app->components->{ $name } = $instance;
}

1;

