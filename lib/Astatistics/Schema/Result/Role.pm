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
package Astatistics::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Astatistics::Schema::Result::Role

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

=head1 TABLE: C<roles>

=cut

__PACKAGE__->table("roles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 role

  data_type: 'char'
  default_value: null
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "role",
  { data_type => "char", default_value => \"null", is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 st_groups_to_roles

Type: has_many

Related object: L<Astatistics::Schema::Result::StGroupsToRole>

=cut

__PACKAGE__->has_many(
  "st_groups_to_roles",
  "Astatistics::Schema::Result::StGroupsToRole",
  { "foreign.role_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 stats_to_roles

Type: has_many

Related object: L<Astatistics::Schema::Result::StatsToRole>

=cut

__PACKAGE__->has_many(
  "stats_to_roles",
  "Astatistics::Schema::Result::StatsToRole",
  { "foreign.role_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_to_roles

Type: has_many

Related object: L<Astatistics::Schema::Result::UsersToRole>

=cut

__PACKAGE__->has_many(
  "users_to_roles",
  "Astatistics::Schema::Result::UsersToRole",
  { "foreign.role" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 st_groups

Type: many_to_many

Composing rels: L</st_groups_to_roles> -> st_group

=cut

__PACKAGE__->many_to_many("st_groups", "st_groups_to_roles", "st_group");

=head2 stats

Type: many_to_many

Composing rels: L</stats_to_roles> -> stat

=cut

__PACKAGE__->many_to_many("stats", "stats_to_roles", "stat");

=head2 users

Type: many_to_many

Composing rels: L</users_to_roles> -> user

=cut

__PACKAGE__->many_to_many("users", "users_to_roles", "user");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-12 11:55:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3s8jH1GTZ3E3/KzZJHRy1Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
