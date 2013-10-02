use utf8;
package Asterisk::Schema::Result::QueueTable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Asterisk::Schema::Result::QueueTable

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

=head1 TABLE: C<queue_table>

=cut

__PACKAGE__->table("queue_table");

=head1 ACCESSORS

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 musiconhold

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 announce

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 context

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 timeout

  data_type: 'integer'
  is_nullable: 1

=head2 monitor_join

  data_type: 'tinyint'
  is_nullable: 1

=head2 monitor_format

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_youarenext

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_thereare

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_callswaiting

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_holdtime

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_minutes

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_seconds

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_lessthan

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_thankyou

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 queue_reporthold

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 announce_frequency

  data_type: 'integer'
  is_nullable: 1

=head2 announce_round_seconds

  data_type: 'integer'
  is_nullable: 1

=head2 announce_holdtime

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 retry

  data_type: 'integer'
  is_nullable: 1

=head2 wrapuptime

  data_type: 'integer'
  is_nullable: 1

=head2 maxlen

  data_type: 'integer'
  is_nullable: 1

=head2 servicelevel

  data_type: 'integer'
  is_nullable: 1

=head2 strategy

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 joinempty

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 leavewhenempty

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 eventmemberstatus

  data_type: 'tinyint'
  is_nullable: 1

=head2 eventwhencalled

  data_type: 'tinyint'
  is_nullable: 1

=head2 reportholdtime

  data_type: 'tinyint'
  is_nullable: 1

=head2 memberdelay

  data_type: 'integer'
  is_nullable: 1

=head2 weight

  data_type: 'integer'
  is_nullable: 1

=head2 timeoutrestart

  data_type: 'tinyint'
  is_nullable: 1

=head2 periodic_announce

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 periodic_announce_frequency

  data_type: 'integer'
  is_nullable: 1

=head2 ringinuse

  data_type: 'tinyint'
  is_nullable: 1

=head2 setinterfacevar

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "name",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "musiconhold",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "announce",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "context",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "timeout",
  { data_type => "integer", is_nullable => 1 },
  "monitor_join",
  { data_type => "tinyint", is_nullable => 1 },
  "monitor_format",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_youarenext",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_thereare",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_callswaiting",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_holdtime",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_minutes",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_seconds",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_lessthan",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_thankyou",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "queue_reporthold",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "announce_frequency",
  { data_type => "integer", is_nullable => 1 },
  "announce_round_seconds",
  { data_type => "integer", is_nullable => 1 },
  "announce_holdtime",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "retry",
  { data_type => "integer", is_nullable => 1 },
  "wrapuptime",
  { data_type => "integer", is_nullable => 1 },
  "maxlen",
  { data_type => "integer", is_nullable => 1 },
  "servicelevel",
  { data_type => "integer", is_nullable => 1 },
  "strategy",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "joinempty",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "leavewhenempty",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "eventmemberstatus",
  { data_type => "tinyint", is_nullable => 1 },
  "eventwhencalled",
  { data_type => "tinyint", is_nullable => 1 },
  "reportholdtime",
  { data_type => "tinyint", is_nullable => 1 },
  "memberdelay",
  { data_type => "integer", is_nullable => 1 },
  "weight",
  { data_type => "integer", is_nullable => 1 },
  "timeoutrestart",
  { data_type => "tinyint", is_nullable => 1 },
  "periodic_announce",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "periodic_announce_frequency",
  { data_type => "integer", is_nullable => 1 },
  "ringinuse",
  { data_type => "tinyint", is_nullable => 1 },
  "setinterfacevar",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->set_primary_key("name");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-09-27 17:40:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KKlby6bdQ/XQ9fIrG5yenw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
