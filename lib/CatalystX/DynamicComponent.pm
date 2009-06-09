package CatalystX::DynamicComponent;
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw/Str CodeRef HashRef ArrayRef/;
use Catalyst::Utils;
use Moose::Util::TypeConstraints;
use List::MoreUtils qw/uniq/;
use namespace::autoclean;

enum __PACKAGE__ . '::ResolveStrategy' => qw/
    merge
    replace
/;

our $VERSION = "0.000000_01";

parameter 'name' => (
    isa => Str,
    required => 1,
);

parameter 'pre_immutable_hook' => (
    isa => CodeRef|Str,
    predicate => 'has_pre_immutable_hook',
);

my $coerceablearray = subtype ArrayRef;
coerce $coerceablearray, from Str, via { [ $_ ] };

my %parameters = (
    methods => {
        isa =>HashRef, 
        default => sub { {} },
        resolve_strategy => 'merge',
    },
    roles => {
        isa => $coerceablearray, coerce => 1,
        default => sub { [] },
        resolve_strategy => 'merge',
    },
    superclasses => {
        isa => $coerceablearray, coerce => 1,
        default => sub { [] },
        resolve_strategy => 'replace',
    },
); 

# Shameless metaprogramming.
foreach my $name (keys %parameters) {
    my $resolve_strategy = delete $parameters{$name}->{resolve_strategy};

    parameter $name, %{ $parameters{$name} };

    parameter $name . '_resolve_strategy' => (
        isa => __PACKAGE__ . '::ResolveStrategy',
        default => $resolve_strategy,
    );
}

# Code refs to implement the strategy types
my %strategies = ( # Right hand precedence where appropriate
    replace => sub { 
        $_[0] = [ $_[0] ] if $_[0] && !ref $_[0];
        $_[1] = [ $_[1] ] if $_[1] && !ref $_[1];
        $_[1] ? $_[1] : $_[0];
    },
    merge => sub {
        $_[0] = [ $_[0] ] if $_[0] && !ref $_[0];
        $_[1] = [ $_[1] ] if $_[1] && !ref $_[1];
        if (ref($_[0]) eq 'ARRAY' || ref($_[1]) eq 'ARRAY') {
            [ uniq( @{ $_[0] }, @{ $_[1] } ) ];
        }
        else {
            Catalyst::Utils::merge_hashes(shift, shift);
        }
    },
);

# Wrap all the crazy up in a method to generically merge configs.
my $get_resolved_config = sub {
    my ($name, $p, $config) = @_;
    my $get_strategy_method_name = $name . '_resolve_strategy';
    my $strategy = $strategies{$p->$get_strategy_method_name()};
    $strategy->($p->$name, $config->{$name})
        || $parameters{$name}->{default}->();
};

role {
    my $p = shift;
    my $name = $p->name;
    my $pre_immutable_hook = $p->pre_immutable_hook;

    method $name => sub {
        my ($app, $name, $config) = @_;
        my $appclass = blessed($app) || $app;

        $config ||= {};

        my $type = $name;
        $type =~ s/::.*$//;

        my $component_name = $appclass . '::' . $name;
        my $meta = Moose->init_meta( for_class => $component_name );

        my @superclasses = @{ $get_resolved_config->('superclasses', $p, $config) };
        push(@superclasses, 'Catalyst::' . $type) unless @superclasses;
        $meta->superclasses(@superclasses);

        my $methods = $get_resolved_config->('methods', $p, $config);
        foreach my $method_name (keys %$methods) {
            next unless $methods->{$method_name}; # Skip explicitly undef methods
            $meta->add_method($method_name => $methods->{$method_name});
        }

        if (my @roles = @{ $get_resolved_config->('roles', $p, $config) }) {
            Moose::Util::apply_all_roles( $component_name, @roles);
        }

        if ($p->has_pre_immutable_hook) {
            if (!ref($pre_immutable_hook)) {
                $app->$pre_immutable_hook($meta, $config);
            }
            else {
                $pre_immutable_hook->($meta, $config);
            }
        }

        $meta->make_immutable;

        my $instance = $app->setup_component($component_name);
        $app->components->{ $component_name } = $instance;
    };
};

1;

__END__

=head1 NAME

CatalystX::DynamicComponent - Parameterised Moose role providing functionality to build Catalyst components at runtime.

=head1 SYNOPSIS

    package My::DynamicComponentType;
    use Moose::Role;
    use namespace::autoclean;

    with 'CatalystX::DynamicComponent' => {
        name => '_setup_one_of_my_components', # Name of injected method
    };

    after setup_components => sub { shift->_setup_all_my_components(@_); };

    sub _setup_all_my_components {
        my ($self, $c) = @_;
        my $app = ref($self) || $self;
        foreach my $component_name ('Controller::Foo') {
            my %component_config = %{ $c->config->{$component_name} };
            # Shallow copy so we avoid stuffing methods back in the config, as that's lame!
            $component_config{methods} = {
                some_method => sub { 'foo' },
            };
                
            # Calling this method creates a component, and registers it in your application
            # This component will subclass 'MyApp::ControllerBase', do 'MyApp::ControllerRole'
            # and have a method called 'some_method' which will return the value 'foo'..
            $self->_setup_one_of_my_components($app . '::' . $component_name, \%component_config);
        }
    }

    package MyApp;
    use Moose;
    use namespace::autoclean;
    use Catalyst qw/
        +My::DynameComponentType
    /;
    __PACKAGE__->config(
        name => 'MyApp',
        'Controller::Foo' => {
            superclasses => [qw/MyApp::ControllerBase/],
            roles => [qw/MyApp::ControllerRole/],
        },
    );
    __PACKAGE__->setup;

=head1 DESCRIPTION

CatalystX::DynamicComponent aims to provide a flexible and reuseable method of building L<Roles|Moose::Role>
which can be added to L<Catalyst> applications, which generate components dynamically at application
startup using the L<Moose> meta model.

Thi is implemented as a parametrised role which curries a
component builder method into your current package at application time.

Authors of specific dynamic component builders are expected implement an application class
roles which composes this role, and their own advice after the C<< setup_compontents >>
method, which will call the component generation method provided by using this role once
for each component you wish to create.

=head1 PARAMETERS

=head2 name

B<Required> - The name of the component generator method to curry.

=head2 methods

Optional, a hash reference with keys being method names, and values being a L<Class::MOP::Method>,
or a plain code ref of a method to apply to
the dynamically generated package before making it immutable.

=head2 roles

Optional, an array reference of roles to apply to the generated component

=head2 superclasses

Optional, an array reference of superclasses to give the generated component.

If this is not defined, and not passed in as an argument to the generation method,
then Catalyst::(Model|View|Controller) will used as the base class (as appropriate given
the requested namespace of the generated class, otherwise Catalyst::Component will be used.

FIXME - Need tests for this.

=head2 pre_immutable_hook

Optional, either a coderef, which will be called with the component $meta and the merged $config,
or a string name of a method to call on the application class, with the same parameters.

This hook is called after a component has been generated and methods added, but before it is made
immutable, constructed, and added to your component registry.

=head1 CURRIED COMPONENT GENERATOR

=head2 ARGUMENTS

=over

=item *

$component_name (E.g. C<< MyApp::Controller::Foo >>)

=item *

$config (E.g. C<< $c->config->{$component_name} >>)

=back

=head3 config

It is possible to set each of the roles, methods and superclasses parameters for each generated package
individually by defining those keys in the C< $config > parameter to your curried component generation method.

By default, roles and methods supplied from the curried role, and those passed as config will be merged.

Superclasses, no the other hand, will replace those from the curried configuration if passed as options.
This is to discourage accidental use of multiple inheritence, if you need this feature enabled, you should
probably be using Roles instead!

It is possible to change the default behavior of each parameter by passing a 
C< $param_name.'_resolve_strategy' > parameter when currying a class generator, with values of either 
C<merge> or C<replace>.

Example:

    package My::ComponentGenerator;
    use Moose;

    with 'CatalystX::DynamicComponent' => {
        name => 'generate_magic_component',
        roles => ['My::Role'],
        roles_resolve_strategy => 'replace',
    };

    package MyApp;
    use Moose;
    use Catalyst qw/
        My::ComponentGenerator
    /;
    extends 'Catalyst';
    after 'setup_components' => sub {
        my ($app) = @_;
        # Component generated has no roles
        $app->generate_magic_component('MyApp::Controller::Foo', { roles => [] });
        # Component generated does My::Role
        $app->generate_magic_component('MyApp::Controller::Foo', {} );
    };
    __PACKAGE__->setup;

=head2 OPERATION

FIXME

=head1 TODO

=over

=item *

Test pre_immutable hook in tests

=item *

More tests fixme?

=item *

Unlame needing to pass fully qualified component name in, that's retarded...

Remember to fix the docs and clients too ;)

=item *

Tests for roles giving advice to methods which have just been added..

=back

=head1 LINKS

L<Catalyst>, L<MooseX::MethodAttributes>,
L<CatalystX::DynamicComponent::ModelsFromConfig>.

=head1 BUGS

Probably plenty, test suite certainly isn't comprehensive.. Patches welcome.

Source code can be found on github:

    http://github.com/bobtfish/catalyst-dynamicappdemo/tree/master

=head1 AUTHOR

Tomas Doran (t0m) <bobtfish@bobtfish.net>

=head1 LICENSE

This code is copyright (c) 2009 Tomas Doran. This code is licensed on the same terms as perl
itself.

=cut

