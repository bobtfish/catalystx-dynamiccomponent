package ExamplePaymentApp;
use Moose;
use Catalyst::Runtime 5.80;
use CatalystX::InjectComponent;
use namespace::autoclean;

extends 'Catalyst';

use Catalyst qw/-Debug
                ConfigLoader
                Static::Simple/;
our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'ExamplePaymentApp',
    environments => [qw/ test qa dev live /],
);

after 'setup_components' => sub {
    my ($app) = @_;

    foreach my $env (@{ $app->config->{environments} }) {
        foreach my $model (grep { s/.+Model::Payment::// } keys %{ $app->components }) {

            my $controller_name = ucfirst($env) . "::" . ucfirst($model);
            my $component_name = "Controller::" . $controller_name;

            $app->config->{$component_name} ||= {};
            $app->config->{$component_name}->{model} ||= $model;
            $app->config->{$component_name}->{environment} ||= $env;

            CatalystX::InjectComponent->inject(
                into => $app,
                component => 'ExamplePaymentApp::ControllerBase::PaymentProvider',
                as => $controller_name,
            );
        }
    }
};

# Start the application
__PACKAGE__->setup();


=head1 NAME

ExamplePaymentApp - Catalyst based application

=head1 SYNOPSIS

    script/examplepaymentapp_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<ExamplePaymentApp::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Tomas Doran

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
