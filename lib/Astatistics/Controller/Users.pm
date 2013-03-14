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

package Astatistics::Controller::Users;
use Moose;
use namespace::autoclean;
use YAML;

BEGIN {extends 'Catalyst::Controller'; }

my $system_roles = { "superuser" => "1",
 										 "can_design" => "1",
};

=head1 NAME

Astatistics::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Astatistics::Controller::Users in Users.');
}

sub login :Local :Args(0) {
	my ($self, $c) = @_;
	$c->stash->{'template'} = 'users/login.tt';
	if ( exists($c->req->params->{'username'}) ) {
		if ($c->authenticate( {
					username => $c->req->params->{'username'},
					password => $c->req->params->{'password'}
				}) )
		{
			## user is signed in
			$c->stash->{'message'} = $c->localize("You are now logged in.");
			$c->response->redirect(
				$c->uri_for($c->controller('Stats')->action_for('show') )
			);
			$c->detach();
			return;
		}
		else {
			$c->stash->{'message'} = $c->localize("Invalid login.");
		}
	}
}

sub logout :Local :Args(0) {
	my ($self, $c) = @_;
	#$c->stash->{'template'} = 'users/logout.tt';
	$c->stash->{'template'} = 'users/login.tt';
	$c->logout();
	$c->stash->{'message'} = $c->localize("You have been logged out.");
}

sub admin :Local :Args(0) {
	my ($self, $c) = @_;
	$c->stash->{'template'} = 'users/admin.tt';
	my $users_rs;
	if ( $c->user_exists() ) {
		if ( $c->check_user_roles('superuser') ) {
			$users_rs = $c->model('Astatistics::User')->search(
																undef,
																{ order_by => 'id ASC' } );
		} else {
			$users_rs = $c->model('Astatistics::User')->search(
																{ 'id' => $c->user->id },
																{ order_by => 'id ASC' } );
		}
		@{$c->stash->{'users'}} = $users_rs->all;
	}
}

sub roles :Local :Args(0) {
	my ($self, $c) = @_;

	$c->stash->{'template'} = 'users/roles.tt';
	$c->stash->{'system_roles'} = $system_roles;
	my $roles_rs;

	if ( $c->user_exists() ) {
		if ( $c->check_user_roles('superuser') ) {
			$roles_rs = $c->model('Astatistics::Role')->search(
																undef,
																{ order_by => 'id ASC' } );
			@{$c->stash->{'roles'}} = $roles_rs->all;
		} else {
			$c->stash->{'message'} = $c->localize("Permission denied");
		}
	}
}

sub role_edit :Local :Args(0) {
	my ($self, $c) = @_;

	$c->stash->{'system_roles'} = $system_roles;

	$c->stash->{'template'} = 'users/role_edit.tt';

	if ( $c->user_exists() ) {
		if ( $c->check_user_roles('superuser') ) {
			if ($c->req->params->{'do_edit'}) {
				my $id = $c->req->params->{'id'};
				my $role = $c->req->params->{'role'};
				my $role_rs = $c->model('Astatistics::Role')->find($id);
				if ($c->stash->{'system_roles'}->{$role}) {
					$c->stash->{'message'} = ucfirst($role) . $c->localize(" is a system role so could not be edited");
				} else {
					if (!$role_rs) {
						$c->stash->{'message'} = $c->localize('Role not found');
					} else {
						$role_rs->role($role);
						$role_rs->update;
						$c->detach('/users/roles');
					}
				}
			} elsif ($c->req->params->{'do_delete'}) {
				my $id = $c->req->params->{'id'};
				my $role = $c->req->params->{'role'};
				if ($c->stash->{'system_roles'}->{$role}) {
					$c->stash->{'message'} = ucfirst($role) . $c->localize(" is a system role so could not be deleted");
				} else {
					my $role_rs = $c->model('Astatistics::Role')->find($id);
					if (!$role_rs) {
						$c->stash->{'message'} = $c->localize('Role not found');
					} else {
						$role_rs->delete;
						$c->detach('/users/roles');
					}
				}
			}

			my $roles_rs = $c->model('Astatistics::Role')->search(
																undef,
																{ order_by => 'id ASC' } );
			# Pasar campos a plantilla
			@{$c->stash->{'roles'}} = $roles_rs->all;
		}
	}
}

sub edit :Local :Args(0) {
	my ($self, $c) = @_;
	$c->stash->{'template'} = 'users/edit.tt';
	my $ok = 0;
	if ( exists($c->req->params->{'id'}) ) {
		my $users_rs;
		my $roles_rs;
		if ( $c->user_exists() ) {
			if ( $c->check_user_roles('superuser') or
					 $c->req->params->{'id'} == $c->user->id) {

				if ($c->req->params->{'do_edit'} or $c->req->params->{'do_delete'}) {
					# Edited from this page. Do changes.
					my $ok = 1;
					my $user_rs = $c->model('Astatistics::User')->find($c->req->params->{'id'});
					if ($c->req->params->{'do_edit'}) {
						$user_rs->username($c->req->params->{'username'}) if $c->req->params->{'username'};
						if ($c->req->params->{'password'}) {
							if ($c->req->params->{'password'} == $c->req->params->{'password2'}) {
								my $salt = "astatistics";
								my $crypted = crypt($c->req->params->{'password'}, $salt);
								$user_rs->password($crypted);
							} else {
								$c->stash->{'message'} = $c->localize("Passwords do not match");
								$ok = 0;
							}
						}
						if ($ok) {
							$user_rs->update();
							$c->stash->{'message'} = $c->localize("User data updated");
							my $roles_rs = $c->model('Astatistics::Role')->search;
							while (my $role_row = $roles_rs->next) {
								my $role = $role_row->role;
								if ($c->req->params->{$role}) {
									my $user_to_role_rs = $c->model('Astatistics::UsersToRole')->find(
															{ user => $user_rs->id,
																role => $role_row->id
															}
														);
									if (!$user_to_role_rs) {
										my $user_to_role_rs = $c->model('Astatistics::UsersToRole')->create(
																{ user => $user_rs->id,
																	role => $role_row->id
																}
															);
										if (!$user_to_role_rs->in_storage) {
											$c->stash->{'message'} .= $c->localize(" but roles could not be added");
										}
									}
								} else {
									my $user_to_role_rs = $c->model('Astatistics::UsersToRole')->find(
															{ user => $user_rs->id,
																role => $role_row->id
															}
														);
									$user_to_role_rs->delete if $user_to_role_rs;
								}
							}
							$c->detach("/users/admin");
						}
					} elsif ($c->req->params->{'do_delete'}) {
						if ($user_rs->delete) {
							my $done = 1;
							my $role_rs = $c->model('Astatistics::UsersToRole')->search({ user => $c->req->params->{'id'} });
							while (my $role_row = $role_rs->next) {
								$done = 0 if (!$role_row->delete);
							}
							if ($done) {
								$c->stash->{'message'} = $c->localize("User deleted successfully");
							} else {
								$c->stash->{'message'} = $c->localize("User deleted but role association could not be deleted");
							}
						} else {
								$c->stash->{'message'} = $c->localize("User could not be deleted");
						}
						$c->detach("/users/admin");
					}
				}

				$users_rs = $c->model('Astatistics::User')->search(
																	{ 'id' => $c->req->params->{'id'} } );
				$roles_rs = $c->model('Astatistics::Role')->search(
																	undef,
																	{ order_by => 'role ASC' } );
				# Pasar campos a plantilla
				@{$c->stash->{'users'}} = $users_rs->all;
				@{$c->stash->{'roles'}} = $roles_rs->all;
				$c->stash->{'id'} = $c->req->params->{'id'};
				$ok = 1;
			}
		}
	}
	$c->detach('/users/admin') if !$ok;
}

sub new_user :Local :Args(0) {
	my ($self, $c) = @_;
	$c->stash->{'template'} = 'users/new.tt';

	my $roles_rs = $c->model('Astatistics::Role')->search(
														undef,
														{ order_by => 'role ASC' } );
	# Pasar campos a plantilla
	@{$c->stash->{'roles'}} = $roles_rs->all;

	if ($c->req->params->{'do_new'}) {
		my $done = 1;
		my $username = $c->req->params->{'username'};
		my $password = $c->req->params->{'password'};
		my $password2 = $c->req->params->{'password2'};

		my $user_exists_rs = $c->model('Astatistics::User')->find({ username => $username });

		if ($user_exists_rs) {
			$c->stash->{'message'} = $c->localize("User with name $username already exists");
		} else {
			if ($password != $password2) {
				$c->stash->{'message'} = $c->localize("Passwords do not match");
				$done = 0;
			} else {
				my $salt = "astatistics";
				my $crypted = crypt($c->req->params->{'password'}, $salt);
				my $user_rs = $c->model('Astatistics::User')->create(
							{ username => $username,
								password => $crypted
							}
						);
				if (!$user_rs->in_storage) {
					$c->stash->{'message'} = $c->localize("Could not create user $username in database");
					$done = 0;
				} else {
					$c->stash->{'message'} = $c->localize("User $username created successfully");
					my $roles_rs = $c->model('Astatistics::Role')->search;
					while (my $role_row = $roles_rs->next) {
						my $role = $role_row->role;
						if ($c->req->params->{$role}) {
							my $user_to_role_rs = $c->model('Astatistics::UsersToRole')->find(
													{ user => $user_rs->id,
														role => $role_row->id
													}
												);
							if (!$user_to_role_rs) {
								my $user_to_role_rs = $c->model('Astatistics::UsersToRole')->create(
														{ user => $user_rs->id,
															role => $role_row->id
														}
													);
								if (!$user_to_role_rs->in_storage) {
									$c->stash->{'message'} .= $c->localize(" but roles could not be added");
								}
							}
						} else {
							my $user_to_role_rs = $c->model('Astatistics::UsersToRole')->find(
													{ user => $user_rs->id,
														role => $role_row->id
													}
												);
							$user_to_role_rs->delete if $user_to_role_rs;
						}
					}
				}
			}
			$c->detach("/users/admin") if $done;
		}
	}
}

sub new_role :Path("/users/new_role") :Args('0') {
	my ($self, $c) = @_;

	$c->stash->{'template'} = 'users/role_new.tt';

	if ($c->req->params->{'role'}) {
		# do_new
		my $role = $c->req->params->{'role'};
		my $roles_rs = $c->model('Astatistics::Role')->find({ role => $role });
		if ($roles_rs) {
			$c->stash->{'message'} = $c->localize("Role $role already exists");
		} else {
			$roles_rs = $c->model('Astatistics::Role')->create({ role => $role });
			if ($roles_rs->in_storage) {
				$c->stash->{'message'} = $c->localize("Role $role created successfully");
				$c->detach('/users/roles');
			} else {
				$c->stash->{'message'} = $c->localize("Role $role could not be created successfully");
			}
		}
	}
}



=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
