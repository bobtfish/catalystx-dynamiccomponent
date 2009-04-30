package DynamicAppDemo::Controller::Root;
use Moose;
use namespace::autoclean;

# Note - need old style actions
# Note - do not extend general controller base class, which messes with
#        action registration!
BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config->{namespace} = '';

sub root : Chained('/') PathPath() CaptureArgs() {}

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

