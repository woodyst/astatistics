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
package Astatistics::Schema::Result::StGroupsToStGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Astatistics::Schema::Result::StGroupsToStGroup

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

=head1 TABLE: C<st_groups_to_st_groups>

=cut

__PACKAGE__->table("st_groups_to_st_groups");

=head1 ACCESSORS

=head2 group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 parent_group_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 position

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "parent_group_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "position",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</group_id>

=item * L</parent_group_id>

=back

=cut

__PACKAGE__->set_primary_key("group_id", "parent_group_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-12 11:55:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NRNxgNfD7tGhI4gltejmFw


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->belongs_to(
  "st_group",
  "Astatistics::Schema::Result::StGroup",
  { id => "group_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);
1;
