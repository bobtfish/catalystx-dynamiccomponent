use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 1;

BEGIN { use_ok 'Catalyst::Test', 'TestComplexApp' }

