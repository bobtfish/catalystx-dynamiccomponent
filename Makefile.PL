# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'DynamicAppDemo';
all_from 'lib/DynamicAppDemo.pm';

requires 'MooseX::Types::Structured' => '0.12';
requires 'namespace::autoclean';
requires 'MooseX::Types' => '0.10';
requires 'MooseX::Role::Parameterized' => '0.05';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Runtime' => '5.80001';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'YAML';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
