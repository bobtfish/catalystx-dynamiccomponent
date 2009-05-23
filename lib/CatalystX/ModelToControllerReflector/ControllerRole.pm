package CatalystX::ModelToControllerReflector::ControllerRole;
use Moose::Role;
use Moose::Util qw/find_meta/;
use namespace::autoclean;

sub get_reflected_action_methods {
    my ($self) = @_;
    my $meta = find_meta($self);

    return  map { $self->_smash_method_attributes($_) }
            grep { ! /^(_|new|meta|get_action_methods)$/ }
                                        # FIXME - giant turd, right there.
            $meta->get_method_list;    # we need to apply a role to the
                                       # metaclass of each method we generate,
                                       # and then test for that role being done
                                       # by the method in question here.
                                        # Should probably also check they supports
                                        # attributes and shit self if not.
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

1;

