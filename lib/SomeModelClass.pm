package SomeModelClass;
use Moose;
use namespace::clean -except => 'meta';

# Note trivial calling convention.
# Apply MX::Method::Signatures and MX::Types::Structured to be less lame.

# Introspection should only reflect methods which satisfy the calling convention
# This is left as an exercise to the reader. :)

sub say_hello {
    my ($self, $name) = @_;
    return("Hello $name");
}

__PACKAGE__->meta->make_immutable;

