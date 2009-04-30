use strict;
use warnings;

# FIXME - Not sure if this does what I think it does, test..

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use List::MoreUtils qw/any/;
use Module::Find;
setmoduledirs("$Bin/../lib", "$Bin/lib");

use Test::More tests => 4;
use Test::Exception;

my @modules;
lives_ok {
    @modules = (useall('CtaalystX'), useall('DynamicAppDemo'));
} 'Use all';
ok @modules;

ok ! any(sub { ! $_->isa('Moose::Object') }, @modules),
    'Moose in da hoose';

ok ! any(sub { $_->can('has') }, @modules),
    'However, no lolcat to be found';

