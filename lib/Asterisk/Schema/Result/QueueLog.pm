use utf8;
package Asterisk::Schema::Result::QueueLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Asterisk::Schema::Result::QueueLog

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

=head1 TABLE: C<queue_log>

=cut

__PACKAGE__->table("queue_log");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 time

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 10

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

=head2 agent

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 event

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 32

=head2 data

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "time",
  { data_type => "char", default_value => "", is_nullable => 0, size => 10 },
  "callid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "queuename",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "agent",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "event",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 32 },
  "data",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-09-27 17:39:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pxHdskP2g3ENgns539855g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
