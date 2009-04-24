package CatalystX::ControllerGeneratingModel;

# Stolen from doy - http://tozt.net/code/Bot-Games/lib/Bot/Games/OO.pm
# Note, this code is not modifier safe, as it doesn't deal with wrapped methods.

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

sub command { # This takes way too much code, surely there must be a better way to 
              # do it?
    my $class = shift;
    my ($name, $code, %args) = @_;
    my $method_meta = $class->meta->get_method($name);
    my $superclass = Moose::blessed($method_meta) || 'Moose::Meta::Method';
    my $method_metaclass = Moose::Meta::Class->create_anon_class(
        superclasses => [$superclass],
        roles        => ['CatalystX::ControllerGeneratingModel::DispatchableMethod'],
        cache        => 1,
    );
    if ($method_meta) {
        $method_metaclass->rebless_instance($method_meta);
    }
    else {
        $method_meta = $method_metaclass->name->wrap(
            $code,
            package_name => $class,
            name         => $name,
        );
        $class->meta->add_method($name, $method_meta);
    }
}

Moose::Exporter->setup_import_methods(
    with_caller => ['command'],
    also        => ['Moose'],
);

sub init_meta {
    shift;
    my %options = @_;
    Moose->init_meta(%options);
#    Moose::Util::MetaRole::apply_metaclass_roles(
#        for_class                 => $options{for_class},
#        attribute_metaclass_roles => ['FooBar::Meta::Role::Attribute'],
#        metaclass_roles           => ['FooBar::Meta::Role::Class'],
#    );
    return $options{for_class}->meta;
}

1;

