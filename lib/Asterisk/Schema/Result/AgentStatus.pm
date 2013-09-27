use utf8;
package Asterisk::Schema::Result::AgentStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Asterisk::Schema::Result::AgentStatus

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

=head1 TABLE: C<agent_status>

=cut

__PACKAGE__->table("agent_status");

=head1 ACCESSORS

=head2 agentid

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 40

=head2 agentname

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 agentstatus

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 callid

  data_type: 'double precision'
  default_value: 0.000000
  extra: {unsigned => 1}
  is_nullable: 1
  size: [18,6]

=head2 queue

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "agentid",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 40 },
  "agentname",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "agentstatus",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "callid",
  {
    data_type => "double precision",
    default_value => "0.000000",
    extra => { unsigned => 1 },
    is_nullable => 1,
    size => [18, 6],
  },
  "queue",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</agentid>

=back

=cut

__PACKAGE__->set_primary_key("agentid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-09-27 17:38:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:b39QjizG/MbAeG44wwntUA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
