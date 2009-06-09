package TestComplexApp::ProfileModelLoader;
use Moose::Role;
use namespace::autoclean;

with 'Catalyst::Component::InstancePerContext';

sub build_per_context_instance {
    my ($self, $c) = @_;
    my $class = blessed($self) || $self;

    my $profile = $self->load_profile($c);

    my $model_class = $c->config->{$class}{class};

    $model_class->new($profile);
};

# Load the given profile
sub load_profile {
	my ($self, $c) = @_;

	my $profile_name = $c->stash->{profile};
	my $enterprise_name = $c->stash->{enterprise};
	
	my $enterprise = $c->model('ProfileDB::Enterprise')->single( # FIXME - push method here down onto custom ResultSet
		{name => $enterprise_name}                               #         class.
	);
	my $profile = $c->model('ProfileDB::Profile')->single(       # FIXME - can has join?
		{name => $profile_name, enterprise_id => $enterprise->id}
	);
	
	my $profile_data = {};
	my $set_rs = $c->model('ProfileDB::ProfileSetting')->search(
		{profile_id => $profile->id}
	);
	while (my $set = $set_rs->next) { # FIXME - use HashReinflator and map if you need it, faster!
		$profile_data->{$set->name} = $set->value;
	}
	
	return $profile_data;
}
	
1;

