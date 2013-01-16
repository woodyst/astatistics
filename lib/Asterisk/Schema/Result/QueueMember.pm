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
package Asterisk::Schema::Result::QueueMember;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Asterisk::Schema::Result::QueueMember

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

=head1 TABLE: C<queue_members>

=cut

__PACKAGE__->table("queue_members");

=head1 ACCESSORS

=head2 uniqueid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 membername

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 queue_name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 interface

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 penalty

  data_type: 'integer'
  is_nullable: 1

=head2 paused

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "uniqueid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "membername",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "queue_name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "interface",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "penalty",
  { data_type => "integer", is_nullable => 1 },
  "paused",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</uniqueid>

=back

=cut

__PACKAGE__->set_primary_key("uniqueid");

=head1 UNIQUE CONSTRAINTS

=head2 C<queue_interface>

=over 4

=item * L</queue_name>

=item * L</interface>

=back

=cut

__PACKAGE__->add_unique_constraint("queue_interface", ["queue_name", "interface"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-04 12:12:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:W5ep2zmJcL4lp5Qa5j6Ntg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
