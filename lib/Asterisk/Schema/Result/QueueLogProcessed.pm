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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-09-27 17:39:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Hm1hadm2gK2vny3spgqK8g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
