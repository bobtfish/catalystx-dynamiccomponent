use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More 'no_plan';

use ExamplePaymentApp;
my $app = ExamplePaymentApp->new;

my $component = $app->components->{'ExamplePaymentApp::Model::Payment::Null'};
is $component->model_class, 'PaymentProvider::Null';
is_deeply $component->interfaces, ['PaymentProviderInterface'];
is_deeply [ sort @{ $component->interface_required_methods } ], [sort qw/ foo bar /];


