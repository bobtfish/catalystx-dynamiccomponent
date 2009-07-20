package ExamplePaymentApp::Schema::ProfileDB::Result::Enterprise;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('enterprise');
__PACKAGE__->add_columns(
    enterprise_id => {
        is_auto_increment => 1,
        data_type => 'INT',
        is_nullable => 0,
    },
    name => {
        data_type => 'VARCHAR',
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key('enterprise_id');

1;

