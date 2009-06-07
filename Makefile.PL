use inc::Module::Install;

name 'CatalystX-DynamicComponent';
all_from 'lib/CatalystX/DynamicComponent.pm';

license 'perl';

requires 'namespace::autoclean';
requires 'MooseX::Types' => '0.10';
requires 'MooseX::Role::Parameterized' => '0.06';
requires 'Catalyst::Runtime' => '5.80004';
requires 'Moose::Autobox' => undef; # ->flatten
requires 'List::MoreUtils';

resources repository => 'git@github.com:bobtfish/catalyst-dynamicappdemo.git';

auto_install;
WriteAll;

