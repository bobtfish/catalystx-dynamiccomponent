package SomeModelClassInterface;
use Moose::Role;
use namespace::autoclean;

requires 'say_hello';

package SomeModelClass;
use Moose;
use CatalystX::ControllerGeneratingModel;
use namespace::autoclean;

# Note trivial calling convention.
# Apply MX::Method::Signatures and MX::Types::Structured to be less lame.

# Introspection should only reflect methods which satisfy the calling convention
# This is left as an exercise to the reader. :)

# Note command syntax not actually needed, this could be a normal sub,
# but doing so makes the eventual merge harder..

command say_hello => sub {
    my ($self, $document) = @_;

    confess("Not a hash") unless (ref($document) eq 'HASH');
    my $name = $document->{name};
    return({ type => 'say_hello_response',

            body => "Hello $name" });
};

with 'SomeModelClassInterface';

__PACKAGE__->meta->make_immutable;

