package CatalystX::ModelToControllerReflector;
use Moose::Role;
use namespace::clean -except => 'meta';

with 'CatalystX::DynamicComponent';

requires 'setup_components';

after 'setup_components' => sub { shift->_setup_dynamic_controllers(@_); };

sub _setup_dynamic_controllers {
    my ($app) = @_;
    my @model_names = grep { /::Model::/ } keys %{ $app->components };
    
    foreach my $model_name (@model_names) {
        $app->_setup_dynamic_controller( $model_name, $app->components->{$model_name} );
    }
}

sub _setup_dynamic_controller {
    my ($app, $model_name, $model_component) = @_;
    warn($model_name);
}

1;

