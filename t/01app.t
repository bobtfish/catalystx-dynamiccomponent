use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'DynamicAppDemo' }

{
    my $res = request('/fakeexample/register_me');
    ok( $res->is_success, 'should succeed' );
    is( $res->header('X-Foo'), 'bar', 'is calling correct code' );
}

