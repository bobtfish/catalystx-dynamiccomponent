package ExamplePaymentApp::Schema::ProfileDB::Result::Profile;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('profile');
__PACKAGE__->add_columns(
    profile_id => {
        is_auto_increment => 1,
        data_type => 'INT',
        is_nullable => 0,
    },
    enterprise_id => {
        is_auto_increment => 0,
        data_type => 'INT',
        is_nullable => 0,
    },
    name => {
        data_type => 'VARCHAR',
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key('profile_id');

1;

