package TestDB;
use strict;
use warnings;
use ExamplePaymentApp::Schema::ProfileDB;
use FindBin qw/$Bin/;
use Exporter ();

our @EXPORT = qw/ schema /;

my $fn = "$Bin/profiledb.sqlite";
my $schema;

sub import {
    unlink("$fn");
    $ENV{CATALYST_HOME} = $Bin; # Make us pick up config and use db in t/
    $schema = ExamplePaymentApp::Schema::ProfileDB->connect("DBI:SQLite:$fn")
      or die "failed to connect to DBI:SQLite:$fn";

    $schema->deploy;

    goto \&Exporter::import;
}

sub schema () { $schema }

1;

