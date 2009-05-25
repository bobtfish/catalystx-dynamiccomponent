use strict;
use warnings;

# FIXME - This is all fairly gross and hacky. Surely there should be a nicer
#         more generic approach.

use FindBin qw/$Bin/;
use lib ("$Bin/lib", "$Bin/../lib");

use List::MoreUtils qw/any all/;
use Module::Find;
setmoduledirs("$Bin/../lib", "$Bin/lib");

use Test::More tests => 5;
use Test::Exception;

my @modules;
lives_ok {
    @modules = (useall('CatalystX'), useall('DynamicAppDemo'));
} 'Use all';
ok @modules;

ok ! any( sub { ! $_->isa('Moose::Object') },
          grep { $_->meta !~ /::Role/   }
          grep { ! $_->can('import')    }
          @modules
    ),
    'Moose in da hoose';

ok ! any(sub { $_->can('has') && warn("$_ can has") && 1; }, @modules),
    'However, no lolcat to be found';

ok all( sub  { $_->meta->is_immutable },
        grep { $_->meta !~ /::Role/   } # Skip roles, ewww. I would test
                                        # ->isa('Moose::Role') but that fails
                                        # for parameterised roles..
        grep { ! $_->can('import')    } # Skip exporters
    @modules),
    'And all classes are immutable';

