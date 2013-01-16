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

package Astatistics::View::TT;

use strict;
use warnings;
use DateTime;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
		expose_methods => [ qw/ user_can_access epoch_to_str_date / ],
);

sub user_can_access {
	my ($self, $c, $class, $id) = @_;

	my $roles_rs;

	if ($class eq "group") {
		$roles_rs = $c->model('Astatistics::StGroup')->find( { id => $id } )->roles;
	} elsif ($class eq "stat") {
		$roles_rs = $c->model('Astatistics::Stat')->find( { id => $id } )->roles;
	}

	$c->log->info("Roles in $class $id:");
	while (my $row = $roles_rs->next) {
		my $role = $row->role;
		my $access = 0;
		$access = 1 if $c->check_user_roles($role);
		return $access if $access;
	}
	return 0;
}

sub epoch_to_str_date {
	my ($self, $c, $epoch) = @_;

	if ($epoch !~ /^[0-9\.]+$/) {
		return $epoch;
	}
	my $dt = DateTime->from_epoch( epoch => $epoch );
	my $str_date = $dt->datetime;
	$str_date =~ s/T/ /g;
	return $str_date;
}


=head1 NAME

Astatistics::View::TT - TT View for Astatistics

=head1 DESCRIPTION

TT View for Astatistics.

=head1 SEE ALSO

L<Astatistics>

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
