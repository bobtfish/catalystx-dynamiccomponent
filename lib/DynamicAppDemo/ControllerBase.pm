package DynamicAppDemo::ControllerBase;
use Moose;
use Moose::Util qw/find_meta/;
use namespace::autoclean;

# You need attributes still for _DISPATCH and friends.
BEGIN { extends 'Catalyst::Controller' }

sub get_reflected_action_methods {
    my ($self) = @_;
    my $meta = find_meta($self);

    return  map { $self->_smash_method_attributes($_) }
            grep { ! /^(_|new|meta)/ }
            $meta->get_method_list;
}

# EPIC CHEAT to just smash the attribute definition :)
sub _smash_method_attributes {
    my ($self, $name) = @_;
    my $meta = find_meta($self);

    my $m = $meta->get_method($name);
    $m->meta->get_attribute('attributes')->set_value($m, ['Local']);
    return $m;
}

around get_action_methods => sub {
    my $orig = shift;
    my $self = shift;
    
    return ($self->get_reflected_action_methods, $self->$orig(@_));
};

__PACKAGE__->meta->make_immutable;

