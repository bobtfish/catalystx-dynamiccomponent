use inc::Module::Install;

name 'CatalystX-DynamicComponent';
all_from 'lib/CatalystX/DynamicComponent.pm';

requires 'MooseX::Types::Structured' => '0.12';
requires 'namespace::autoclean';
requires 'MooseX::Types' => '0.10';
requires 'MooseX::Role::Parameterized' => '0.05';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Runtime' => '5.80003';
auto_install;
extra_texts; # Need to install Module::Install::ExtraTests 
WriteAll;
