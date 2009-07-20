package ExamplePaymentApp::Model::Payment::Null;
use Moose;
use namespace::autoclean;

extends 'ExamplePaymentApp::ModelBase::WithProfile';

__PACKAGE__->config(
    model_class => 'PaymentProvider::Null',
    interfaces => ['PaymentProviderInterface'],
);

__PACKAGE__->meta->make_immutable;

