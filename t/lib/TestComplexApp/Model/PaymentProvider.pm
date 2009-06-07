package TestComplexApp::Model::PaymentProvider;
use Moose;
use Moose::Meta::Class;
use namespace::autoclean;

extends 'Catalyst::Model';

=head1 NAME

PaymentApp::Model::PaymentProvider - Provider Model factory

=head1 DESCRIPTION 

This module creates dynamic Catalyst Models based on configured
payment providers and the requested payment profile. 

The Model instance is created at request time, not at setup time, and
so we can inspect the message to see which enterprise and profile is
required. We then load that profile using the ProfileDB Model, and
instantiate the Model. The corresponding generated controller then
invokes the appropriate method on this Model.

We create a Model class per configured payment provider, and we
require this configuration:

  Model::PaymentProvider:
    providers:
      - PaymentProvider::Datacash
      - PaymentProvider::Cybersource
      - PaymentProvider::Null

The Model instances may be accessed like so:

  $c->model('PaymentProvider::Datacash')

with the enterprise and profile names in the stash.

=head1 TODO

More graceful handling of missing enterprise and/or profile. We should
do something other than just not return a model. 

=head1 SEE ALSO

PaymentApp::Controller::PaymentProvider - this module's partner in crime.

=cut

sub COMPONENT {
	my $self = shift->next::method(@_);
	
	my $provider_classes = $self->{providers};

	for my $provider_class (@$provider_classes) {
		eval "require $provider_class";
		if ($@) {
			die "loading $provider_class: $@";
		}
		
		my $provider_model_name = "PaymentApp::Model::${provider_class}";
		my $provider = Moose::Meta::Class->create($provider_model_name);
		$provider->add_method('ACCEPT_CONTEXT', 
				      sub {
					      my ($model, $c) = @_;
					      my $profile = $self->load_profile($c);
					      my $provider_model = $provider_class->new($profile);
					      return $provider_model;
				      });
	}

	return $self;
}

# Load the given profile and instantiate the provider
sub load_profile {
	my ($self, $c) = @_;

	my $profile_name = $c->stash->{profile};
	my $enterprise_name = $c->stash->{enterprise};
	
	my $enterprise = $c->model('ProfileDB::Enterprise')->single(
		{name => $enterprise_name}
	);
	my $profile = $c->model('ProfileDB::Profile')->single(
		{name => $profile_name, enterprise_id => $enterprise->id}
	);
	
	my $profile_data = {};
	my $set_rs = $c->model('ProfileDB::ProfileSetting')->search(
		{profile_id => $profile->id}
	);
	while (my $set = $set_rs->next) {
		$profile_data->{$set->name} = $set->value;
	}
	
	return $profile_data;
}
	
1;

