package ExamplePaymentApp::Schema::ProfileDB::Result::ProfileSetting;
use strict;
use warnings;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('profile_setting');
__PACKAGE__->add_columns(
    profilesetting_id => {
        is_auto_increment => 1,
        data_type => 'INT',
        is_nullable => 0,
    },
    profile_id => {
        is_auto_increment => 0,
        data_type => 'INT',
        is_nullable => 0,
    },
    name => {
        data_type => 'VARCHAR',
        is_nullable => 0,
    },
    value => {
        data_type => 'VARCHAR',
        is_nullable => 0, # ? undef valid ?
    },
);
__PACKAGE__->set_primary_key('profilesetting_id');

1;

