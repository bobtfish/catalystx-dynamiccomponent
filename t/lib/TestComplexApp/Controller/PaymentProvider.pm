package TestComplexApp::Controller::PaymentProvider;
use Moose;
use Moose::Meta::Class;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; };

=head1 NAME

PaymentApp::Controller::PaymentProvider - Provider Controller factory

=head1 DESCRIPTION

This module creates dynamic Catalyst controllers based on
configuration. It's intended for use with Catalyst::Engine::Stomp,
where each controller namespace corresponds to a message queue
subscription.

The generated controllers expect Model classes to be defined for the
configured payment providers, as configured by
PaymentApp::Model::PaymentProvider - and in fact we borrow that
module's config.

We create one controller for each configured payment provider, for
each configured environment. The generated namespace is based on both
these names, so you end up with queues like "live_datacash". 

The relevant configuration comes from Catalyst, and should resemble
this:

  Model::PaymentProvider:
    providers:
      - PaymentProvider::Datacash
      - PaymentProvider::Cybersource
      - PaymentProvider::Null

  Controller::PaymentProvider:
    environments:
      - qa
      - test
      - custqa
      - uat

=head1 TODO

We're currently hardcoding the list of methods which form the
interface to a payment processor. This will change - we will require
that a payment provider class "does" a Moose role, and that role will
indicate the methods we should consider dispatchable. 

=head1 SEE ALSO

PaymentApp::Model::PaymentProvider - this module's partner in crime.

=cut

__PACKAGE__->config( namespace => '' );

sub COMPONENT {
	my $self = shift->next::method(@_);
	
	# Sneakily borrow our corresponding model's config for providers
	my $model_config = $self->_app->config->{'Model::PaymentProvider'};
	my $provider_classes = $model_config->{providers};

	# Environment list is from our own config. 
	my $environments = $self->{environments};
	
	# For each configured provider/environment combination, create
	# a Controller class which dispatches a set of methods to the
	# provider's Model.
	for my $provider_class (@$provider_classes) {
		for my $environment (@$environments) {

			# Compose the name of the Controller
			my $env_class = ucfirst($environment);
			my $provider_controller_name = "Controller::${provider_class}::${env_class}";

			# Compose its namespace - i.e. the STOMP queue name
			my $namespace = $environment . '_' . $provider_class->name;
			$self->_app->config( $provider_controller_name => { namespace => $namespace } );

			# Create the class with Moose
			my $provider = Moose::Meta::Class->create("PaymentApp::${provider_controller_name}");
			$provider->superclasses('PaymentApp::ControllerBase::Message');

			# XXX from interface role, not static list here!
			my @dispatchable_methods = qw/ payment_auth_request
						       payment_settle_request
						       payment_refund_request
						     /;
			
			# Attach a method for each action, making sure
			# to apply the right method attribute to turn
			# these into actions
			for my $method_name (@dispatchable_methods) {
				my $sub = sub {
					my ($self, $c, $message) = @_;
					my $provider_model = $c->model($provider_class);
					my $response = $provider_model->$method_name($message);
					$c->stash->{response} = $response;
				};
				
				# Why doesn't add_method return the method?
				$provider->add_method($method_name, $sub);
				my $method = $provider->get_method($method_name);
				$provider->register_method_attributes($method->body, ['Local']);
			}
		}
	}

	return $self;
}
	
__PACKAGE__->meta->make_immutable;

