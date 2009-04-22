package DynamicAppDemo::Controller::Root;
use Moose;

# Note - need old style actions
# Note - do not extend general controller base class, which messes with
#        action registration!
BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config->{namespace} = '';

sub end : ActionClass('RenderView') {}

__PACKAGE__->meta->make_immutable;

