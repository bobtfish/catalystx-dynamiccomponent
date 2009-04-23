package CatalystX::ModelToControllerReflector;
use Moose::Role;
use namespace::clean -except => 'meta';

with 'CatalystX::DynamicComponent' 
    => { alias => { _setup_dynamic_component => '_setup_dynamic_controller' } };

requires 'setup_components';

after 'setup_components' => sub { shift->_setup_dynamic_controllers(@_); };

sub _setup_dynamic_controllers {
    my ($app) = @_;
    my @model_names = grep { /::Model::/ } keys %{ $app->components };
    
    foreach my $model_name (@model_names) {
        $app->_reflect_model_to_controller( $model_name, $app->components->{$model_name} );
    }
}

sub _reflect_model_to_controller {
    my ( $app, $model_name, $model ) = @_;

    my $controller_name = $model_name;
    $controller_name =~ s/::Model::/::Controller::/;

    $app->_setup_dynamic_controller( $controller_name );
}

1;

