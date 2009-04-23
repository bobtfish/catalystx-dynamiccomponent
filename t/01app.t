use strict;
use warnings;
use Test::More tests => 6;

BEGIN { use_ok 'Catalyst::Test', 'DynamicAppDemo' }

{
    my $res = request('/fakeexample/register_me');
    ok( $res->is_success, 'should succeed' );
    is( $res->header('X-Foo'), 'bar', 'is calling correct code' );
}

{
    my $res = request('/one/say_hello/world');
    ok( $res->is_success, 'should succeed' );
    is( $res->header('X-From-Model'), 'One' );
    is( $res->header('X-From-Model-Data'), 'Hello world' ); 
}

