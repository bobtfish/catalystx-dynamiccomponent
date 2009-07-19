use inc::Module::Install;

BEGIN {
    if ($Module::Install::AUTHOR) {
        require Module::Install::AuthorRequires;
        require Module::Install::AuthorTests;
    }
}

name 'CatalystX-DynamicComponent';
all_from 'lib/CatalystX/DynamicComponent.pm';

license 'perl';

requires 'namespace::autoclean';
requires 'MooseX::Types' => '0.10';
requires 'MooseX::Role::Parameterized' => '0.06';
requires 'Catalyst::Runtime' => '5.80004';
requires 'Moose::Autobox' => undef; # ->flatten
requires 'List::MoreUtils';

test_requires 'Catalyst::Model::Adaptor' => '0.04';

author_requires 'Test::Pod';
author_requires 'Test::EOL';
author_requires 'Test::NoTabs';

author_tests('t/author');

resources repository => 'git@github.com:bobtfish/catalyst-dynamicappdemo.git';

auto_install;
WriteAll;

