package ExamplePaymentApp::ControllerBase::PaymentProvider;
use Moose;
use Moose::Meta::Class;
use MooseX::Types::Moose qw/ Str /;
use MooseX::Types::Common::String qw/ NonEmptySimpleStr /;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::MessageDriven'; };

has _action_namespace => ( isa => Str, is => 'ro', required => 1, init_arg => undef, lazy_build => 1 );

sub _build__action_namespace {
    my ($self) = @_;
    confess("No env") unless $self->environment;
    confess("No model") unless $self->model;
    lc($self->environment . '_' . $self->model);
}

sub action_namespace { shift->_action_namespace }

has model => ( isa => NonEmptySimpleStr, is => 'ro', required => 1 );

has environment => ( isa => NonEmptySimpleStr, is => 'ro', required => 1 );

sub BUILD {
    my ($self) = @_;
    $self->action_namespace; # Ensure value built
}

before get_action_methods => sub {
    my ($self) = @_;
    my $model_component_name = $self->_app . '::Model::Payment::' . $self->model;
    my $model_component = $self->_app->components->{$model_component_name} || confess(ref($self)
        . " cannot find a model component named $model_component_name in " . join(', ',
        keys(%{$self->_app->components})) . ')');
    my @dispatchable_methods = @{ $model_component->interface_required_methods };

    my $meta = $self->meta;
    # Attach a method for each action, making sure
    # to apply the right method attribute to turn
    # these into actions
    for my $method_name (@dispatchable_methods) {
        my $sub = sub {
            my ($self, $c, $message) = @_;
            $c->stash->{profile} = $self->environment;
            $c->stash->{enterprise} = $message->{enterprise};
            my $response = $c->model('Payment::' . $self->model)->$method_name($message);
            $c->stash->{response} = $response;
        };

        # Why doesn't add_method return the method?
        $meta->add_method($method_name, $sub);
        my $method = $meta->get_method($method_name);
        $meta->register_method_attributes($method->body, ['Local']);
    }
    # Becoming immutable here neatly makes this class a singleton.
    $meta->make_immutable;
    return $self;
};

# And become immutable here so you can't construct the base class..
__PACKAGE__->meta->make_immutable;

