package DynamicAppDemo::ControllerBase;
use Moose;
use namespace::clean -except => 'meta';

# Should not need attributes here, but what the hell..
BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->meta->make_immutable;

