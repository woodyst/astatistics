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
package Asterisk::Schema::Result::Cdr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Asterisk::Schema::Result::Cdr

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

=head1 TABLE: C<cdr>

=cut

__PACKAGE__->table("cdr");

=head1 ACCESSORS

=head2 calldate

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 clid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 src

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 dst

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 dcontext

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 channel

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 dstchannel

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 lastapp

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 lastdata

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 80

=head2 duration

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 billsec

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 disposition

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 45

=head2 amaflags

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 accountcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=head2 userfield

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 uniqueid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 linkedid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 sequence

  accessor: 'column_sequence'
  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 peeraccount

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=cut

__PACKAGE__->add_columns(
  "calldate",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "clid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "src",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "dst",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "dcontext",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "channel",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "dstchannel",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "lastapp",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "lastdata",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 80 },
  "duration",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "billsec",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "disposition",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 45 },
  "amaflags",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "accountcode",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "userfield",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "uniqueid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "linkedid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "sequence",
  {
    accessor => "column_sequence",
    data_type => "varchar",
    default_value => "",
    is_nullable => 0,
    size => 32,
  },
  "peeraccount",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</clid>

=item * L</channel>

=item * L</calldate>

=back

=cut

__PACKAGE__->set_primary_key("clid", "channel", "calldate");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-07-04 12:12:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wP+34J+tuLkkvsuzOG6PKg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
