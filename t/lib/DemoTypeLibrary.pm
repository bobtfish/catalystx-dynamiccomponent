package DemoTypeLibrary;

use MooseX::Types 
    -declare => [qw(
        MessageDocument
    )];

use MooseX::Types::Moose qw/Str/;
use MooseX::Types::Structured qw/Dict/;

subtype MessageDocument,
    as Dict[
        name => Str,
        type => Str,
    ];


1;

