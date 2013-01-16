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

package Astatistics::View::GP_PDF;

use strict;
use base 'Catalyst::View::Graphics::Primitive';

__PACKAGE__->config(
											driver => 'Cairo',
											driver_args =>
																{ format => 'pdf' },
											content_type => 'application/pdf',
);


=head1 NAME

Astatistics::View::GP_PDF - Catalyst Graphics::Primitive View

=head1 SYNOPSIS

See L<Astatistics>

=head1 DESCRIPTION

Catalyst Graphics::Primitive View.

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
