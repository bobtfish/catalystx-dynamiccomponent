package TestComplexApp;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Catalyst;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config( name => 'TestComplexApp' );

__PACKAGE__->setup();

1;

