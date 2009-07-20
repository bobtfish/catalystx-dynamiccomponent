package ExamplePaymentApp::ModelBase::WithProfile;
use Moose;
use MooseX::Types::Moose qw/Object ClassName RoleName ArrayRef/;
use MooseX::Types::Common::String qw/NonEmptySimpleStr/;
use Moose::Util::TypeConstraints;
use Moose::Util qw/find_meta/;
use namespace::autoclean;

extends 'Catalyst::Model';
with 'Catalyst::Component::InstancePerContext';

has profile_model => ( isa => NonEmptySimpleStr, is => 'ro', default => 'ProfileDB' );

my $classname = subtype ClassName, where { 1 };
coerce $classname, from NonEmptySimpleStr, via { Class::MOP::load_class($_); $_; };

has model_class => ( isa => $classname, coerce => 1, is => 'ro', required => 1 );

my $arrayofroles = subtype ArrayRef[RoleName], where { 1 };
coerce $arrayofroles, from ArrayRef, via { for my $mod (@$_) { Class::MOP::load_class($mod); }; $_; };

has interfaces => ( isa => $arrayofroles, coerce => 1, is => 'ro', required => 1, default => sub { [] } );

has anon_class => (
    isa => Object, is => 'ro', required => 1,
    lazy_build => 1, init_arg => undef,
);

sub _build_anon_class {
    my ($self) = @_;
    return $self->class unless scalar @{ $self->interfaces };
    my $meta = Class::MOP::Class->create_anon_class(
        superclasses => [ $self->model_class ],
        roles => $self->interfaces,
        cache => 1,
    );
    $meta;
}

has interface_required_methods => ( isa => ArrayRef[NonEmptySimpleStr], is => 'ro', lazy_build => 1, init_arg => undef );

sub _build_interface_required_methods {
    my ($self) = @_;
    return [
        map { $_->name }
        map { find_meta($_)->get_required_method_list }
        @{ $self->interfaces }
    ];
}

sub build_per_context_instance {
    my ($self, $c) = @_;
    my $class = blessed($self) || $self;

    my $profile = $self->load_profile($c);

    $self->anon_class->name->new($profile);
};

# Load the given profile
sub load_profile {
    my ($self, $c) = @_;

    my $profile_name = $c->stash->{profile} || confess('$c->stash->{profile} not set');
    my $enterprise_name = $c->stash->{enterprise} || confess('$c->stash->{enterprise} not set');

    my $model = $c->model($self->profile_model);
    # FIXME - Push down into the model!
    my $enterprise = $model->resultset('Enterprise')->single(
        {name => $enterprise_name}                               #         class.
    );
    my $profile = $model->resultset('Profile')->single(       # FIXME - can has join?
        {name => $profile_name, enterprise_id => $enterprise->id}
    );

    my $profile_data = {};
    my $set_rs = $model->resultset('ProfileSetting')->search(
        {profile_id => $profile->id}
    );
    while (my $set = $set_rs->next) { # FIXME - use HashReinflator and map if you need it, faster!
        $profile_data->{$set->name} = $set->value;
    }

    return $profile_data;
}

1;

