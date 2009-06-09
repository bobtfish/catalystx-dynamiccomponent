package CatalystX::DynamicComponent::ModelsFromConfig;
use Moose::Role;
use Catalyst::Utils;
use namespace::autoclean;

requires qw/
    config
    setup_components
    setup_component
/;

# Note method reaming - allows user to modify my setup_dynamic_component without being
#                       forced to do it globally.
with 'CatalystX::DynamicComponent' => {
    name => '_setup_dynamic_model',
    methods => {
        COMPONENT => sub {
            my ($component_class_name, $app, $args) = @_;

            my $class = $args->{class};
            Class::MOP::load_class($class);
	    
            $class->new($args);
        },
    },
};

after 'setup_components' => sub { shift->_setup_dynamic_models(@_); };

sub _setup_dynamic_models {
    my ($app) = @_;

    my $model_prefix = 'Model::';

    my $config = $app->config || {};
    my $myconfig = $config->{'CatalystX::DynamicComponent::ModelsFromConfig'} || {};

    foreach my $model_name ( grep { /^$model_prefix/ } keys %$config ) {
        if (my $inc = $myconfig->{include}) {
            next unless $model_name =~ /$inc/;
        }
        if (my $exc = $myconfig->{exclude}) {
            next if $model_name =~ /$exc/;
        }
        $app->_setup_dynamic_model( $model_name, 
            $app->_setup_dynamic_model_config( $model_name, 
                Catalyst::Utils::merge_hashes($myconfig, $config->{$model_name}) )
        );
    }
}

sub _setup_dynamic_model_config {
    my ($app, $model_name, $config) = @_;
    return $config;
}

1;

__END__

=head1 NAME

CatalystX::DynamicComponent::ModelsFromConfig - Generate simple L<Catalyst::Model::Adaptor> like models purely from application config.

=head1 SYNOPSIS

    package MyApp;
    use Moose;
    use namespace::autoclean;
    use Catalyst qw/
        +CatalystX::DynamicComponent::ModelsFromConfig
    /;
    __PACKAGE__->config(
        name => __PACKAGE__,
        'CatalystX::DynamicComponent::ModelsFromConfig' => {
            include => '(One|Two|Three)^',
            exclude => 'Tewnty',
        },
        'Model::One' => {
            class => 'SomeClass', # Name of class to load and construct
            other => 'config',    # Constructor passed other parameters
        },
        'Model::Two' => {
            class => 'SomeOtherClass',
            other => 'config',
        },
        ...
        'Model::TwentyThree' => { # Ignored, as excluded
        ...
    );
    __PACKAGE__->setup;

=head1 DESCRIPTION

FIXME

=head1 LINKS

L<Catalyst>, L<MooseX::MethodAttributes>, L<CatalystX::DynamicComponent>.

=head1 BUGS

Probably plenty, test suite certainly isn't comprehensive.. Patches welcome.

=head1 AUTHOR

Tomas Doran (t0m) <bobtfish@bobtfish.net>

=head1 LICENSE

This code is copyright (c) 2009 Tomas Doran. This code is licensed on the same terms as perl
itself.

=cut

