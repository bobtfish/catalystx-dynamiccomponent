package ExamplePaymentApp::Model::ProfileDB;
use strict;
use warnings;
use ExamplePaymentApp ();
use base qw/Catalyst::Model::DBIC::Schema/;

__PACKAGE__->config(
    schema_class => 'ExamplePaymentApp::Schema::ProfileDB',
    connect_info => {
        dsn => "dbi:SQLite:" . ExamplePaymentApp->path_to('profiledb.sqlite'),
        user => "username",
        password => "password",
    }
);

1;

