# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;

name 'DynamicAppDemo';
all_from 'lib/DynamicAppDemo.pm';

requires 'Catalyst::Runtime' => '5.80002';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'YAML';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
