package PaymentProvider::Null;
use Moose;
use namespace::autoclean;

has attribute_one => ( is => 'ro' );
has attribute_two => ( is => 'rw' );

sub foo {
    warn("In foo");
    { }
}

sub bar {
    my $self = shift;
    { one => $self->attribute_one, two => $self->attribute_two };
}

__PACKAGE__->meta->make_immutable;

