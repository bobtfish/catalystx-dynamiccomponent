use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Test::More 'no_plan';
use YAML;
use TestDB;
use Data::Dumper;

BEGIN { use_ok 'CatalystX::Test::MessageDriven', 'ExamplePaymentApp' };

my $queue = 'qa_null';
my $message = { type => 'foo', enterprise => 'somecustomer' };

{
    my $res = request($queue, Dump($message));
    ok $res;
    is $res->code, 400;
    my $data = Load($res->content);
    is $data->{status}, 'ERROR';
}

{   # FIXME - use ::fixtures of something..
    my $e = schema()->resultset('Enterprise')->new({ name => 'somecustomer' });
    $e->insert;
    my $p = schema()->resultset('Profile')->new({ enterprise_id => $e->id, name => 'qa' });
    $p->insert;
    my %config = (
        attribute_one => 'somevalue',
        attribute_two => 'someothervalue',
    );
    while (my ($k, $v) = each %config) {
        schema()->resultset('ProfileSetting')->new({
            profile_id => $p->id, name => $k, value => $v
        })->insert;
    }
}

{
    my $res = request($queue, Dump($message));
    ok $res;
    is $res->code, 200;
    my $data = Load($res->content);
    is_deeply($data, {});
}

$message->{type} = 'bar';

{
    my $res = request($queue, Dump($message));
    ok $res;
    is $res->code, 200;
    my $data = Load($res->content);
    is_deeply($data,  { one => 'somevalue', two => 'someothervalue' });
}

$message->{type} = 'quux';

{
    my $res = request($queue, Dump($message));
    ok $res;
    is $res->code, 400;
    my $data = Load($res->content);
    is($data->{status}, 'ERROR');
}

