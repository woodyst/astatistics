#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.

# This file is part of Astatistics.
# Copyright (C) 2011
# 	Eurogaran Informatica, S.L.
# 
# Astatistics is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Astatistics is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Astatistics.  If not, see <http://www.gnu.org/licenses/>.
# 
# See the file COPYING for copying conditions.

use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Astatistics';
all_from 'lib/Astatistics.pm';

# External: wkhtmltopdf, libtest-nowarnings-perl
requires 'DateTime';
requires 'DateTime::Format::MySQL';
requires 'Params::Validate' => '0.97';
requires 'Class::CSV';
requires 'Test::Output';
requires 'Test::NoWarnings';
requires 'Module::Runtime';
requires 'Hash::MultiValue';
requires 'namespace::autoclean' => '0.13';
requires 'YAML::Tiny';
requires 'DBD::SQLite';
requires 'DateTime::Format::SQLite';
requires 'SQL::Translator';
requires 'Class::DBI';
requires 'DBIx::Class';
requires 'Object::Signature';
requires 'File::Remove';
requires 'Task::Catalyst';
requires 'Catalyst::Runtime' => '5.80025';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::ScriptRole';
requires 'Catalyst::Script::Server';
requires 'Catalyst::View::TT' => '0.39';
requires 'CatalystX::Component::Traits' => '0.16';
requires 'Catalyst::Devel' => '1.37';
requires 'Catalyst::Plugin::Session::Store::FastMmap' => '0.16';
requires 'Catalyst::Plugin::Session::State::Cookie' => '0.17';
requires 'Catalyst::Plugin::Authorization::Roles' => '0.06';
requires 'Catalyst::Authentication::Store::DBIx::Class' => '0.1503';
requires 'Catalyst::View::Wkhtmltopdf';
requires 'Catalyst::Helper::View::Wkhtmltopdf';
requires 'Catalyst::Helper::View::JSON';
requires 'Catalyst::ScriptRunner';
requires 'Catalyst::Restarter';
requires 'Moose' => '2.06020';
requires 'Graphics::Color::RGB';
requires 'Graphics::Primitive';
requires 'Catalyst::Helper::View::Graphics::Primitive';
requires 'Layout::Manager';
requires 'Paper::Specs';
requires 'DBIx::Class::ResultSet';
requires 'DBIx::Class::Schema::Loader';
requires 'Chart::Clicker';
#requires 'Class::DBI::Plugin::DeepAbstractSearch';	# test
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
