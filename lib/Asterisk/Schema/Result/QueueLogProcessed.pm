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
package Asterisk::Schema::Result::QueueLogProcessed;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Asterisk::Schema::Result::QueueLogProcessed

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

=head1 TABLE: C<queue_log_processed>

=cut

__PACKAGE__->table("queue_log_processed");

=head1 ACCESSORS

=head2 recid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 origid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 callid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 queuename

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 agentdev

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 event

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 data1

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 data2

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 data3

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 datetime

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "recid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "origid",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "callid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "queuename",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "agentdev",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "event",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "data1",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "data2",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "data3",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "datetime",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</recid>

=back

=cut

__PACKAGE__->set_primary_key("recid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-04 12:12:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RDOefQmpHorns+Z4OfDkww


# You can replace this text with custom content, and it will be preserved on regeneration
1;
