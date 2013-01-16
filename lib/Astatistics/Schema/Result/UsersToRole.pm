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

use utf8;
package Astatistics::Schema::Result::UsersToRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Astatistics::Schema::Result::UsersToRole

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<users_to_roles>

=cut

__PACKAGE__->table("users_to_roles");

=head1 ACCESSORS

=head2 user

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0
  size: 11

=head2 role

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0
  size: 11

=cut

__PACKAGE__->add_columns(
  "user",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0, size => 11 },
  "role",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0, size => 11 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user>

=item * L</role>

=back

=cut

__PACKAGE__->set_primary_key("user", "role");

=head1 RELATIONS

=head2 role

Type: belongs_to

Related object: L<Astatistics::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Astatistics::Schema::Result::Role",
  { id => "role" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user

Type: belongs_to

Related object: L<Astatistics::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Astatistics::Schema::Result::User",
  { id => "user" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-12 11:55:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:z3p101/pbfuuoeSNIBanqA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
