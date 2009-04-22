package DynamicAppDemo::ControllerBase;
use Moose;
use Moose::Util qw/find_meta/;
use namespace::clean -except => 'meta';

# Should not need attributes here, but what the hell..
BEGIN { extends 'Catalyst::Controller' }

around get_action_methods => sub {
    my $orig = shift;
    my $self = shift;

    my $meta = find_meta($self);
    
    # FIXME - fugly, and nasty
    return (
        (   map { 
                my $m = $meta->get_method($_);
                # EPIC CHEAT to just smash the attribute definition :)
                $m->meta->get_attribute('attributes')->set_value($m, ['Local']);
                $m;
            }
            grep { ! /^(_|new|meta)/ }
            $meta->get_method_list
        ),
        (
            $self->$orig(@_)
        )
    ); 
};

__PACKAGE__->meta->make_immutable;

