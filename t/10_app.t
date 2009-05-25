use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 4;

BEGIN { use_ok 'Catalyst::Test', 'DynamicAppDemo' }

{
    my $res = request('/one/say_hello/world');
    ok( $res->is_success, 'should succeed' );
    is( $res->header('X-From-Model'), 'One' );
    is( $res->header('X-From-Model-Data'), 'Hello world' ); 
}

