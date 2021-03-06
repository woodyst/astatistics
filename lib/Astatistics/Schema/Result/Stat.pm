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
package Astatistics::Schema::Result::Stat;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Astatistics::Schema::Result::Stat

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

=head1 TABLE: C<stats>

=cut

__PACKAGE__->table("stats");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 visual

  data_type: 'char'
  default_value: 'list'
  is_nullable: 0
  size: 32

=head2 conditions

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 format

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "char", default_value => "", is_nullable => 0, size => 32 },
  "visual",
  { data_type => "char", default_value => "list", is_nullable => 0, size => 32 },
  "conditions",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "format",
  { data_type => "text", default_value => "", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 stats_to_roles

Type: has_many

Related object: L<Astatistics::Schema::Result::StatsToRole>

=cut

__PACKAGE__->has_many(
  "stats_to_roles",
  "Astatistics::Schema::Result::StatsToRole",
  { "foreign.stat_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 stats_to_st_groups

Type: has_many

Related object: L<Astatistics::Schema::Result::StatsToStGroup>

=cut

__PACKAGE__->has_many(
  "stats_to_st_groups",
  "Astatistics::Schema::Result::StatsToStGroup",
  { "foreign.stat_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</stats_to_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "stats_to_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-12 11:55:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ru6FhZEJ3OwTFD7RbNIYGA


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->many_to_many( groups => 'stats_to_st_groups', 'group');
1;
