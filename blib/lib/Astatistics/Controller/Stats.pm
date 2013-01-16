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

package Astatistics::Controller::Stats;
use Moose;
use namespace::autoclean;
use YAML;
use Data::Dumper;
use DateTime;
use DateTime::Format::MySQL;
use Graphics::Primitive;
use Class::CSV;
use Chart::Clicker;
use Chart::Clicker::Decoration::OverAxis;
use Chart::Clicker::Context;
use Chart::Clicker::Data::DataSet;
use Chart::Clicker::Data::Marker;
use Chart::Clicker::Data::Series;
use Chart::Clicker::Data::Series::Size;
use Chart::Clicker::Axis;
use Chart::Clicker::Axis::DateTime;
use Graphics::Primitive::Font;
use Graphics::Primitive::Brush;
use Geometry::Primitive::Rectangle;
use Graphics::Color::RGB;
use Chart::Clicker::Renderer::Area;
use Chart::Clicker::Renderer::Bar;
use Chart::Clicker::Renderer::Bubble;
use Chart::Clicker::Renderer::CandleStick;
use Chart::Clicker::Renderer::Line;
use Chart::Clicker::Renderer::Pie;
use Chart::Clicker::Renderer::Point;
use Chart::Clicker::Renderer::PolarArea;
use Chart::Clicker::Renderer::StackedArea;
use Chart::Clicker::Renderer::StackedBar;
use Layout::Manager;
use Paper::Specs;
use base 'Catalyst::View::TT';

BEGIN {extends 'Catalyst::Controller'; }

my $system_roles = { "superuser" => 1,
										 "can_design" => 1,
};

=head1 NAME

Astatistics::Controller::Stats - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

		if ($c->user_exists) {
			$c->detach('/stats/show');
		} else {
			$c->detach('/users/login');
		}
}

sub show :Chained :Path("/stats/show") :Args() {
	my ($self, $c) = @_;
	$c->stash->{'template'} = 'stats/show.tt';

	my $path = $c->request->path;		# stats/show/2/3/4
	$c->log->debug("Path: $path");

	my $statpath = $path;
	$statpath =~ s/^stats\/show//;
	$statpath =~ s/^stats//;
	$statpath =~ s/^\///;						# 2/3/4
	my @statpath = split("/",$statpath);	# 2, 3, 4
	$c->stash->{'statpath'} = $statpath;
	my $parent_path = $statpath;
	$parent_path =~ s/\/*[^\/]+$//;
	$c->stash->{'parent_path'} = $parent_path;

	## Now we can get this level doing 'pop @statpath' and parent doing it again, or
	## $statpath[$#statpath] and $statpath[$#statpath - 1], as a tree directory structure.
	## Testing paths:
	#$c->res->body("Your path is $path, statpath is $statpath");
	#return 0;
	## Test end

	$c->stash->{'level'} = $statpath[-1] ? $statpath[-1] : 1;
	my $level = $c->stash->{'level'};
	$c->log->info("LEVEL: $level");
	my $parent_dir = $statpath;								 # 2/3/4
	my $last_statpath = $statpath[-1] ? $statpath[-1] : "";
	$parent_dir =~ s/$last_statpath$//;
	$parent_dir =~ s/\/$//;
	$parent_dir = 1 if !$parent_dir;
	$c->stash->{'parent_dir'} = "$parent_dir";		# 2/3
	my $parent = $statpath;
	$parent =~ s/.*\///;
	$parent = 1 if !$parent;
	$c->stash->{'parent'} = $parent;

	$c->log->info("STATPATH_ROOT=$statpath, PARENT=$parent");

	#$c->res->body("Your path is $path, statpath is $statpath, level " . $c->stash->{'level'} . ", parent " . $c->stash->{'parent'});
	#return 0;

	# Path with names
	my (@localpath, @parentlocalpath);
	my @tmp_statpath = @statpath;

	for my $gid (@tmp_statpath) {
		my $grs = $c->model('Astatistics::StGroup')->find({ 'id' => $gid });
		#$c->log->info("id: ". $grs->id . ", name: " . $grs->name);
		if (defined $grs) {
			push @localpath, $grs->name;
			push @parentlocalpath, $grs->name;
		}
	}
	pop @parentlocalpath;
	$c->stash->{'localpath'} = join("/", @localpath);
	$c->stash->{'parentlocalpath'} = join("/", @parentlocalpath);

	my $localpath = $c->stash->{'localpath'};

	my $group = $c->model('Astatistics::StGroup')->search(
																			{ 'id' => $c->stash->{'level'} },
																			{ order_by => 'id ASC' } )->next;

	# (@) groups and stats are two many_to_many relationships:
	# What groups/stats has this group? See StatsToStGroup.pm and StGroupsToStGroup.pm
	$c->stash->{'current_group'} = $group;

	# TODO: Order:
	# 			Generar resultset ordenado y publicar en vez de pasar el original
	#				Botones de subir/bajar en plantilla para cambiar orden, que actualizan
	#				parent y también incrementan/decrementan los parents de las otras entradas
	#				afectadas (se hace en StGroupsToStGroup y StatsToStGroup).
	#
	#				Consultas:
	#				SELECT st_group.id, st_group.name, st_group.parent, st_group.after FROM st_groups_to_st_groups me  JOIN st_groups st_group ON st_group.id = me.group_id WHERE ( me.parent_group_id = ? ): '1'
	#				SELECT stat.id, stat.name, stat.visual, stat.conditions, stat.format, stat.after FROM stats_to_st_groups me  JOIN stats stat ON stat.id = me.stat_id WHERE ( me.group_id = ? ): '1'
	@{$c->stash->{'groups'}} = $group->groups(undef, { order_by => [ 'position ASC','id ASC' ] }) if ($group);
	@{$c->stash->{'stats'}} = $group->stats(undef, { order_by => [ 'position ASC','id ASC' ] }) if ($group);

	my $stat = $c->model('Astatistics::Stats');
	@{$c->stash->{'group_roles'}} = $group->roles if ($group);
	@{$c->stash->{'stat_roles'}} = $stat->roles if ($stat);
}

sub templates :Chained :Path("/stats/templates") :Args() {
	my ($self, $c) = @_;
	$c->stash->{'system_roles'} = $system_roles;

	my $path = $c->request->path;		# stats/templates/2/3/4
	$c->log->debug("Path: $path");
	my ($new,$new_from_clipboard,$do_new,$stat_edit,$group_edit,$template_up,$template_down,$group_up,$group_down,$do_edit,$stat_delete,$group_delete,$do_delete,$id_stat,$paste);
	
	$do_new = 1 if ($path =~ s/\/*do_new\/*$//);
	$new = 1 if ($path =~ s/\/*new\/*$//);
	$new_from_clipboard = 1 if ($path =~ s/\/*new_from_clipboard\/*$//);
	$stat_edit = 1 if ($path =~ s/\/*stat_edit\/*$//);
	$group_edit = 1 if ($path =~ s/\/*group_edit\/*$//);
	$template_up = 1 if ($path =~ s/\/*template_up\/*$//);
	$template_down = 1 if ($path =~ s/\/*template_down\/*$//);
	$group_up = 1 if ($path =~ s/\/*group_up\/*$//);
	$group_down = 1 if ($path =~ s/\/*group_down\/*$//);
	$do_edit = 1 if ($path =~ s/\/*do_edit\/*$//);
	$do_delete = 1 if ($path =~ s/\/*do_delete\/*$//);
	$stat_delete = 1 if ($path =~ s/\/*stat_delete\/*$//);
	$group_delete = 1 if ($path =~ s/\/*group_delete\/*$//);
	$paste = 1 if ($path =~ s/\/*paste\/*$//);

	my $cut = $c->req->params->{'cut'};
	my $copy = $c->req->params->{'copy'};
	my $cut_parent = $c->req->params->{'cut_parent'};
	my $cut_class = $c->req->params->{'cut_class'};

	$c->stash->{'clipboard_msg'} = "Cut $cut_class id $cut, parent $cut_parent" if ($cut);
	$c->stash->{'clipboard_msg'} = "Copied $cut_class id $copy" if ($copy);

	$c->log->info("Clipboard contents:  cut: $cut, copy: $copy, cut_parent: $cut_parent, cut_class: $cut_class") if ($cut or $copy);

	if ($new) {
		$c->log->debug("NEW template!");
		$c->stash->{'template'} = 'stats/template_edit.tt';
		$c->stash->{'action'} = 'new';
	} elsif ($new_from_clipboard) {
		$c->log->debug("DO NEW template from clipboard values!");
		$c->stash->{'template'} = 'stats/template_edit.tt';
		$c->stash->{'action'} = 'new_from_clipboard';
	} elsif ($do_new) {
		$c->log->debug("DO NEW template!");
		$c->stash->{'template'} = 'stats/templates.tt';
		$c->stash->{'action'} = 'do_new';
	} elsif ($stat_edit) {
		$c->log->debug("EDIT Template!");
		$c->stash->{'template'} = 'stats/template_edit.tt';
		$c->stash->{'action'} = 'edit_template';
	} elsif ($group_edit) {
		$c->log->debug("EDIT Group!");
		$c->stash->{'template'} = 'stats/template_edit.tt';
		$c->stash->{'action'} = 'edit_group';
		$c->stash->{'edit_name'} = $c->req->params->{'edit_name'};
	} elsif ($template_up) {
		$c->log->debug("UP Template!");
		$c->stash->{'template'} = 'stats/templates.tt';
		$c->stash->{'action'} = 'template_up';
	} elsif ($template_down) {
		$c->log->debug("DOWN Template!");
		$c->stash->{'template'} = 'stats/templates.tt';
		$c->stash->{'action'} = 'template_down';
	} elsif ($group_up) {
		$c->log->debug("UP Group!");
		$c->stash->{'template'} = 'stats/templates.tt';
		$c->stash->{'action'} = 'group_up';
	} elsif ($group_down) {
		$c->log->debug("DOWN Group!");
		$c->stash->{'template'} = 'stats/templates.tt';
		$c->stash->{'action'} = 'group_down';
	} elsif ($do_edit) {
		$c->log->debug("DO_EDIT template!");
		$c->stash->{'template'} = 'stats/template_edit.tt';
		$c->stash->{'action'} = 'do_edit';
	} elsif ($stat_delete) {
		$c->log->debug("DELETE template!");
		$c->stash->{'template'} = 'stats/template_del.tt';
		$c->stash->{'action'} = 'stat_delete';
	} elsif ($group_delete) {
		$c->stash->{'template'} = 'stats/template_del.tt';
		$c->stash->{'action'} = 'group_delete';
	} else {
		$c->stash->{'template'} = 'stats/templates.tt';
	}


	my $statpath = $path;
	$statpath =~ s/^stats\/templates//;
	$statpath =~ s/^\///;						# 2/3/4
	my @statpath = split("/",$statpath);	# 2, 3, 4
	$c->stash->{'statpath'} = $statpath;
	my $parent_path = $statpath;
	$parent_path =~ s/\/*[^\/]+$//;
	$c->stash->{'parent_path'} = $parent_path;

	## Now we can get this level doing 'pop @statpath' and parent doing it again, or
	## $statpath[$#statpath] and $statpath[$#statpath - 1], as a tree directory structure.
	## Testing paths:
	#$c->res->body("Your path is $path, statpath is $statpath");
	#return 0;
	## Test end

	$c->stash->{'level'} = $statpath[-1] ? $statpath[-1] : 1;
	my $parent_dir = $statpath;								 # 2/3/4
	my $last_statpath = $statpath[-1] ? $statpath[-1] : "";
	$parent_dir =~ s/$last_statpath$//;
	$parent_dir =~ s/\/$//;
	$parent_dir = 1 if !$parent_dir;
	$c->stash->{'parent_dir'} = "$parent_dir";		# 2/3
	my $parent = $statpath;
	$parent =~ s/.*\///;
	$parent = 1 if !$parent;
	$c->stash->{'parent'} = $parent;

	$c->log->info("STATPATH_ROOT=$statpath, PARENT=$parent");

	#$c->res->body("Your path is $path, statpath is $statpath, level " . $c->stash->{'level'} . ", parent " . $c->stash->{'parent'});
	#return 0;

	# Actions
	if ($new_from_clipboard) {
		$c->stash->{'new_from_clipboard'} = 1;
		my $clipboard_id;
		if ($cut) {
			$clipboard_id = $cut;
		} elsif ($copy) {
			$clipboard_id = $copy;
		} else {
			$c->stash->{'message'} = "Clipboard has no contents";
			return 0;
		}
		if ($cut_class eq "group") {
			my $rs = $c->model('Astatistics::StGroup')->find($clipboard_id);
			if ($rs) {
				$c->req->params->{'class'} = "group";
				$c->req->params->{'name'} = $rs->name;
				my $roles_rs = $rs->roles;
				while (my $role = $roles_rs->next) {
					$c->req->params->{$role->role} = 1;
				}
			} else {
				$c->stash->{'message'} = "Could not found $cut_class $clipboard_id";
				return 0;
			}
		} elsif ($cut_class eq "template") {
			my $rs = $c->model('Astatistics::Stat')->find($clipboard_id);
			if ($rs) {
				$c->req->params->{'class'} = "template";
				$c->req->params->{'name'} = $rs->name;
				$c->req->params->{'visual'} = $rs->visual;
				$c->req->params->{'conditions'} = $rs->conditions;
				$c->req->params->{'format'} = $rs->format;
				my $roles_rs = $rs->roles;
				while (my $role = $roles_rs->next) {
					$c->req->params->{$role->role} = 1;
				}
			} else {
				$c->stash->{'message'} = "Could not found $cut_class $clipboard_id";
				return 0;
			}
		}
		$c->stash->{'message'} = "New $cut_class copied from id $clipboard_id";
		$c->req->params->{"new"} = "new";
		$new = "new";
		$c->stash->{'action'} = 'new';
	}
	my $action = $c->stash->{'action'};
	if ($do_new or $do_edit or $do_delete) {
		my ($class, $name, $visual, $conditions, $format) = ($c->req->params->{'class'}, $c->req->params->{'name'}, $c->req->params->{'visual'}, $c->req->params->{'conditions'}, $c->req->params->{'format'});
		if ($c->req->params->{'oldname'}) {
			$c->stash->{'oldname'} = $c->req->params->{'oldname'};
		} else {
			$c->stash->{'oldname'} = $c->req->params->{'name'};
		}
		if ($do_new) {
			$c->stash->{'action'} = "new";
			if (!$class) {
				$c->stash->{'message'} = "Class not correctly set";
				$c->stash->{'template'} = 'stats/template_edit.tt';
			} elsif (!$name) {
				$c->stash->{'message'} = "Name not correctly set";
				$c->stash->{'template'} = 'stats/template_edit.tt';
			} elsif ($class eq "group") {
				$c->forward('do_new_group');
			} elsif ($class eq "template") {
				$c->forward('do_new_stat');
			} else {
				$c->stash->{'template'} = 'stats/template_do_new.tt';
				$c->stash->{'message'} = "Template class not found";
			}
		} elsif ($do_edit) {
			$c->stash->{'template'} = 'stats/template_edit.tt';
			$c->forward('do_edit');
		} elsif ($do_delete) {
			$c->stash->{'template'} = 'stats/templates.tt';
			$c->forward('do_delete');
		}
	} elsif ($group_edit or $stat_edit or $stat_delete or $group_delete) {
		$c->stash->{'edit'} = 1;
		if ($c->req->params->{'oldname'}) {
			$c->stash->{'oldname'} = $c->req->params->{'oldname'};
		} else {
			$c->stash->{'oldname'} = $c->req->params->{'name'};
		}
		if ($group_edit) {
			$c->stash->{'class'} = "group";
		} elsif ($stat_edit) {
			$c->stash->{'class'} = "template";
		}
		my $statpath = $c->stash->{'statpath'};
		$c->forward('edit');
	} elsif ($paste) {
		$c->stash->{'template'} = 'stats/templates.tt';
		$c->forward('do_paste');
	} elsif ($action =~ /(template|group)_(up|down)/) {
		$c->forward('set_position');
	}
	# End Actions

	# Path with names
	my (@localpath, @parentlocalpath);
	my @tmp_statpath = @statpath;
	#my $tmp_first = shift @tmp_statpath;
	#if ($tmp_first != 1) {
	#	unshift @tmp_statpath, $tmp_first;
	#}
	for my $gid (@tmp_statpath) {
		my $grs = $c->model('Astatistics::StGroup')->find({ 'id' => $gid });
		#$c->log->info("id: ". $grs->id . ", name: " . $grs->name);
		if (defined $grs) {
			push @localpath, $grs->name;
			push @parentlocalpath, $grs->name;
		}
	}
	pop @parentlocalpath;
	$c->stash->{'localpath'} = join("/", @localpath);
	$c->stash->{'parentlocalpath'} = join("/", @parentlocalpath);

	my $localpath = $c->stash->{'localpath'};

	my $group = $c->model('Astatistics::StGroup')->search(
																			{ 'id' => $c->stash->{'level'} },
																			{ order_by => 'id ASC' } )->next;

	# (@) groups and stats are two many_to_many relationships:
	# What groups/stats has this group? See StatsToStGroup.pm and StGroupsToStGroup.pm
	$c->stash->{'current_group'} = $group;
	@{$c->stash->{'groups'}} = $group->groups(undef, { order_by => [ 'position ASC','id ASC' ] }) if ($group);
	@{$c->stash->{'stats'}} = $group->stats(undef, { order_by => [ 'position ASC','id ASC' ] }) if ($group);

	my $roles_rs = $c->model('Astatistics::Role')->search(
														undef,
														{ order_by => 'id ASC' } );
	# Pasar campos a plantilla
	@{$c->stash->{'roles'}} = $roles_rs->all;
}

sub do_new_group :Private {
	my ($self, $c) = @_;

	my ($class, $name, $visual, $conditions, $format) = ($c->req->params->{'class'}, $c->req->params->{'name'}, $c->req->params->{'visual'}, $c->req->params->{'conditions'}, $c->req->params->{'format'});

	my $statpath = $c->stash->{'statpath'};
	my $parent = $c->stash->{'statpath'};
	$parent =~ s/.*\///;
	$parent = 1 if !$parent;

	my $group_rs = $c->model('Astatistics::StGroup')->find({ name => $name });
	if (defined $group_rs) {
		$c->stash->{'message'} = "Group name $name already used. Please, try another.";
		$c->stash->{'template'} = 'stats/template_edit.tt';
	} else {
		my $group_rs = $c->model('Astatistics::StGroup')->create(
																							{
																								name				=> $name,
																								#visual			=> $visual,
																								#conditions	=> $conditions,
																								#format			=> $format,
																								#parent			=> $parent,
																							});
		if ($group_rs->in_storage) {
			# Get ID
			$group_rs = $c->model('Astatistics::StGroup')->find({ name => $name });
			my $id = $group_rs->id;
			$c->stash->{'message'} = "New group $name in $parent added successfully (id $id)";
			my $grouptogroup_rs = $c->model('Astatistics::StGroupsToStGroup')->search({ -or => [ group_id => $id, parent_group_id => $id ]});
			$grouptogroup_rs->delete if (defined $grouptogroup_rs);
			$grouptogroup_rs = $c->model('Astatistics::StGroupsToStGroup')->create(
																							{
																								group_id				=> $id,
																								parent_group_id	=> $parent,
																								position						=> 0
																							});
			if (!$grouptogroup_rs->in_storage) {
				$c->stash->{'message'} .= ". Nevertheless it wasn't possible adding parent, so undoing.";
				$group_rs = $c->model('Astatistics::StGroup')->delete($id);
			} else {
				$c->stash->{'message'} = ucfirst($class) . " $name (id $id) updated successfully";
				my $roles_rs = $c->model('Astatistics::Role')->search;
				while (my $role_row = $roles_rs->next) {
					my $role = $role_row->role;
					if ($class eq "group") {
						if ($c->req->params->{$role}) {
							my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->find(
													{ st_group_id => $id,
														role_id => $role_row->id
													}
												);
							if (!$st_group_to_role_rs) {
								my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->create(
														{ st_group_id => $id,
															role_id => $role_row->id
														}
													);
								if (!$st_group_to_role_rs->in_storage) {
									$c->stash->{'message'} .= " but roles could not be added";
								}
							}
						} else {
							my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->find(
													{ st_group_id => $id,
														role_id => $role_row->id
													}
												);
							$st_group_to_role_rs->delete if $st_group_to_role_rs;
						}
					} elsif ($class eq "template") {
						if ($c->req->params->{$role}) {
							my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->find(
													{ stat_id => $id,
														role_id => $role_row->id
													}
												);
							if (!$stat_to_role_rs) {
								my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->create(
														{ stat_id => $id,
															role_id => $role_row->id
														}
													);
								if (!$stat_to_role_rs->in_storage) {
									$c->stash->{'message'} .= " but roles could not be added";
								}
							}
						} else {
							my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->find(
													{ stat_id => $id,
														role_id => $role_row->id
													}
												);
							$stat_to_role_rs->delete if $stat_to_role_rs;
						}
					}
				}
			}
		} else {
			$c->stash->{'message'} = "New group $name in $parent was not successfully added";
		}
	}
}

sub do_new_stat :Private {
	my ($self, $c) = @_;

	my ($class, $name, $visual, $conditions, $format) = ($c->req->params->{'class'}, $c->req->params->{'name'}, $c->req->params->{'visual'}, $c->req->params->{'conditions'}, $c->req->params->{'format'});

	my $parent = $c->stash->{'parent'};

	if (!$visual) {
		$c->stash->{'message'} = "Visual not correctly set";
		$c->stash->{'template'} = 'stats/template_edit.tt';
	} else {
		# Do-New Template
		my $stat_rs = $c->model('Astatistics::Stat')->find({ name => $name });
		if (defined $stat_rs) {
			$c->stash->{'message'} = "Template name $name already used. Please, try another.";
			$c->stash->{'template'} = 'stats/template_edit.tt';
		} else {
			my $stat_rs = $c->model('Astatistics::Stat')->create(
																								{
																									name				=> $name,
																									visual			=> $visual,
																									conditions	=> $conditions,
																									format			=> $format,
																									#parent			=> $parent,
																								});
			if ($stat_rs->in_storage) {
				# Get ID
				$stat_rs = $c->model('Astatistics::Stat')->find({ name => $name });
				my $id = $stat_rs->id;
				$c->stash->{'message'} = "New Template $name in $parent added successfully (id $id)";
				my $stattogroup_rs = $c->model('Astatistics::StatsToStGroup')->search({ stat_id => $id });
				$stattogroup_rs->delete if (defined $stattogroup_rs);
				$c->log->debug("Stat to Group addition: ID -> $id, Parent -> $parent");
				$stattogroup_rs = $c->model('Astatistics::StatsToStGroup')->create(
																								{
																									stat_id				=> $id,
																									group_id			=> $parent,
																									position					=> 0,
																								});
				if (!$stattogroup_rs->in_storage) {
					$c->stash->{'message'} .= ". Nevertheless it wasn't possible adding parent, so undoing.";
					$stat_rs = $c->model('Astatistics::Stat')->delete($id);
				} else {
					$c->stash->{'message'} = ucfirst($class) . " $name (id $id) updated successfully";
					my $roles_rs = $c->model('Astatistics::Role')->search;
					while (my $role_row = $roles_rs->next) {
						my $role = $role_row->role;
						if ($class eq "group") {
							if ($c->req->params->{$role}) {
								my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->find(
														{ st_group_id => $id,
															role_id => $role_row->id
														}
													);
								if (!$st_group_to_role_rs) {
									my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->create(
															{ st_group_id => $id,
																role_id => $role_row->id
															}
														);
									if (!$st_group_to_role_rs->in_storage) {
										$c->stash->{'message'} .= " but roles could not be added";
									}
								}
							} else {
								my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->find(
														{ st_group_id => $id,
															role_id => $role_row->id
														}
													);
								$st_group_to_role_rs->delete if $st_group_to_role_rs;
							}
						} elsif ($class eq "template") {
							if ($c->req->params->{$role}) {
								my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->find(
														{ stat_id => $id,
															role_id => $role_row->id
														}
													);
								if (!$stat_to_role_rs) {
									my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->create(
															{ stat_id => $id,
																role_id => $role_row->id
															}
														);
									if (!$stat_to_role_rs->in_storage) {
										$c->stash->{'message'} .= " but roles could not be added";
									}
								}
							} else {
								my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->find(
														{ stat_id => $id,
															role_id => $role_row->id
														}
													);
								$stat_to_role_rs->delete if $stat_to_role_rs;
							}
						}
					}
				}
			} else {
				$c->stash->{'message'} = "New template $name in $parent was not successfully added";
			}
		}
	}
}

sub edit :Private {
	my ($self, $c) = @_;

	my $rs;

	my $id = $c->req->params->{'id'};
	my $class = $c->stash->{'class'};
	if ($c->req->params->{'class'}) {
		$class = $c->req->params->{'class'};
	}

	my %has_role;
	my $role_rel_rs;
	if ($class eq "group") {
		$rs = $c->model('Astatistics::StGroup')->find({ id => $id });

		$role_rel_rs = $c->model('Astatistics::StGroupsToRole')->search({ st_group_id => $id });
	} elsif ($class eq "template") {
		$rs = $c->model('Astatistics::Stat')->find({ id => $id });

		$role_rel_rs = $c->model('Astatistics::StatsToRole')->search({ stat_id => $id });
	}

	while (my $row_rel = $role_rel_rs->next) {
		my $role_row = $c->model('Astatistics::Role')->find($row_rel->role_id);
		if ($role_row) {
			my $role_name = $role_row->role;
			$has_role{$role_name} = 1;
		}
	}

	%{$c->stash->{'has_role'}} = %has_role;

	if (!defined $rs) {
		$c->stash->{'message'} = ucfirst($class) . " id $id does not exist.";
		$c->stash->{'template'} = 'stats/templates.tt';
	} else {
		my $name = $rs->name;
		$c->log->info("Name: $name");
		$c->stash->{'name'} = $name;
		$c->req->params->{'name'} = $name;
		$c->stash->{'oldname'} = $name;
		if ($class eq "template") {
			my $visual = $rs->visual;
			my $conditions = $rs->conditions;
			my $format = $rs->format;
			$c->req->params->{'visual'} = $visual;
			$c->req->params->{'conditions'} = $conditions;
			$c->req->params->{'format'} = $format;
		}
	}
}

sub do_edit :Private {
	my ($self, $c) = @_;

	my $rs;

	my $id = $c->req->params->{'id'};
	my $class = $c->req->params->{'class'};

	my $oldname = $c->stash->{'oldname'};
	$c->log->info("oldname: $oldname");
	$c->log->info("id: $id");

	if ($class eq "group") {
		$rs = $c->model('Astatistics::StGroup')->find({ id => $id });
	} elsif ($class eq "template") {
		$rs = $c->model('Astatistics::Stat')->find({ id => $id });
	}

	if (!defined $rs) {
		$c->stash->{'message'} = "Template id $id does not exist.";
		$c->stash->{'template'} = 'stats/templates.tt';
	} else {
		my ($name,$visual,$conditions,$format) = ($c->req->params->{'name'},$c->req->params->{'visual'},$c->req->params->{'conditions'},$c->req->params->{'format'});
		my @not_defined;
		push (@not_defined, "Name") if ! $name;
		push (@not_defined, "Visual") if (! $visual and $class eq "template");
		$c->stash->{'message'} = join(",", @not_defined) . " not correctly set" if @not_defined;
		$rs->name($name);
		if ($class eq "template") {
			$rs->visual($visual);
			$rs->conditions($conditions);
			$rs->format($format);
		}
		if ($rs->update) {
			$c->stash->{'message'} = ucfirst($class) . " $name (id $id) updated successfully";
			my $roles_rs = $c->model('Astatistics::Role')->search;
			while (my $role_row = $roles_rs->next) {
				my $role = $role_row->role;
				if ($class eq "group") {
					if ($c->req->params->{$role}) {
						my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->find(
												{ st_group_id => $id,
													role_id => $role_row->id
												}
											);
						if (!$st_group_to_role_rs) {
							my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->create(
													{ st_group_id => $id,
														role_id => $role_row->id
													}
												);
							if (!$st_group_to_role_rs->in_storage) {
								$c->stash->{'message'} .= " but roles could not be added";
							}
						}
					} else {
						my $st_group_to_role_rs = $c->model('Astatistics::StGroupsToRole')->find(
												{ st_group_id => $id,
													role_id => $role_row->id
												}
											);
						$st_group_to_role_rs->delete if $st_group_to_role_rs;
					}
				} elsif ($class eq "template") {
					if ($c->req->params->{$role}) {
						my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->find(
												{ stat_id => $id,
													role_id => $role_row->id
												}
											);
						if (!$stat_to_role_rs) {
							my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->create(
													{ stat_id => $id,
														role_id => $role_row->id
													}
												);
							if (!$stat_to_role_rs->in_storage) {
								$c->stash->{'message'} .= " but roles could not be added";
							}
						}
					} else {
						my $stat_to_role_rs = $c->model('Astatistics::StatsToRole')->find(
												{ stat_id => $id,
													role_id => $role_row->id
												}
											);
						$stat_to_role_rs->delete if $stat_to_role_rs;
					}
				}
			}
		} else {
			$c->stash->{'message'} = "Error updating $class $name (id $id)";
		}
		$c->stash->{'template'} = 'stats/templates.tt';
	}
}

sub do_delete :Private {
	my ($self, $c) = @_;

	my $parent = $c->stash->{'parent'};

	my $rs;
	my $stop = 0;

	my $id = $c->req->params->{'id'};
	my $class = $c->req->params->{'class'};
	$c->log->info("class: $class, id: $id, parent: $parent");

	my $oldname = $c->req->params->{'oldname'};

	if ($class eq "group") {
		my $child_rs = $c->model('Astatistics::StGroupsToStGroup')->find({ parent_group_id => $id });
		if (defined $child_rs) {
			$c->stash->{'message'} = "You have to delete group contents first";
			return 0;
		} else {
			$rs = $c->model('Astatistics::StGroupsToStGroup')->search({ -and =>
																																		[ group_id => $id,
																																			parent_group_id => $parent,
																																		]
																																})->next;
		}
	} elsif ($class eq "template") {
		$rs = $c->model('Astatistics::StatsToStGroup')->search({ -and =>
																																[ stat_id => $id,
																																	group_id => $parent,
																																]
																														})->next;
	}

	if (!defined $rs) {
		$c->stash->{'message'} = ucfirst($class) . " id $id does not exist in $parent.";
		$c->stash->{'template'} = 'stats/templates.tt';
	} else {
		if ($rs->delete) {
			$c->stash->{'message'} = ucfirst($class) . " $oldname (id $id) deleted successfully from $parent";
			if ($class eq "group") {
				my $is_present = $c->model('Astatistics::StGroupsToStGroup')->search(
																				{ group_id => $id })->find;
				if (!defined $is_present) {
					$rs = $c->model('Astatistics::StGroup')->find($id);
					$rs->delete;
				}
			} elsif ($class eq "template") {
				my $is_present = $c->model('Astatistics::StatsToStGroup')->search(
																				{ stat_id => $id })->find;
				if (!defined $is_present) {
					$rs = $c->model('Astatistics::Stat')->find($id);
					$rs->delete;
				}
			}
		} else {
			$c->stash->{'message'} = "Error deleting $class $oldname (id $id)";
		}
		$c->stash->{'template'} = 'stats/templates.tt';
	}
}

sub do_paste :Private {
	my ($self, $c) = @_;

	my $parent = $c->stash->{'parent'};
	my $cut_parent = $c->req->params->{'cut_parent'};
	my $copy = $c->req->params->{'copy'};
	my $cut = $c->req->params->{'cut'};
	my $cut_class = $c->req->params->{'cut_class'};

	my $rs;

	my $from;
	my $id;

	if ($copy) {
		$from = "copy";
		$id = $copy;
	} elsif ($cut) {
		$from = "cut";
		$id = $cut;
	}
	$c->log->info("Paste $cut_class from $from, id $id, parent $parent, cut_parent $cut_parent");

	if ($cut_class eq "group") {
		my $group_row = $c->model('Astatistics::StGroup')->find($id);
		if ($group_row) {
			my $name = $group_row->name;
			my $child_rs = $c->model('Astatistics::StGroupsToStGroup')->find(
				{ group_id => $id, parent_group_id => $parent });
			if (defined $child_rs) {
				$c->stash->{'message'} = "Group $name (id $id) is already in this group";
				return 0;
			} else {
				$rs = $c->model('Astatistics::StGroupsToStGroup')->create(
					{	group_id => $id, parent_group_id => $parent } );
				if ($rs->in_storage) {
					$c->stash->{'message'} = "Group $name (id $id) added to group $parent";
					if ($cut) {
						my $child_rs = $c->model('Astatistics::StGroupsToStGroup')->search(
							{ group_id => $id, parent_group_id => $cut_parent })->next;
						if ($child_rs->delete) {
							$c->stash->{'message'} .= " and deleted from group id $cut_parent";
						} else {
							$c->stash->{'message'} .= ", but could not be deleted from group id $cut_parent (cut action)";
						}
					}
				} else {
					$c->stash->{'message'} = "Group $name (id $id) could not be added to group $parent";
				}
			}
		} else {
			$c->stash->{'message'} = "Group with id $id was deleted before paste action";
		}
	} elsif ($cut_class eq "template") {
		my $stat_row = $c->model('Astatistics::Stat')->find($id);
		if ($stat_row) {
			my $name = $stat_row->name;
			$rs = $c->model('Astatistics::StatsToStGroup')->find(
				{ stat_id => $id,	group_id => $parent	});
			if (defined $rs) {
				$c->stash->{'message'} = "Stat $name (id $id) is already in this group";
			} else {
				$rs = $c->model('Astatistics::StatsToStGroup')->create(
					{ stat_id => $id, group_id => $parent });
				if ($rs->in_storage) {
					$c->stash->{'message'} = "Stat $name (id $id) added to group $parent";
					if ($cut) {
						my $child_rs = $c->model('Astatistics::StatsToStGroup')->search(
							{ stat_id => $id, group_id => $cut_parent })->next;
						if ($child_rs->delete) {
							$c->stash->{'message'} .= " and deleted from group id $cut_parent";
						} else {
							$c->stash->{'message'} .= ", but could not be deleted from group id $cut_parent (cut action)";
						}
					}
				} else {
					$c->stash->{'message'} = "Stat $name (id $id) could not be added to group $parent";
				}
			}
		} else {
			$c->stash->{'message'} = "Stat with id $id was deleted before paste action";
		}
	}
}

sub stat_show_gp :Private {
	my ($self, $c) = @_;

	$c->stash->{'graph'} = 1;

	my %conditions = %{$c->stash->{'h_conditions'}};
	my %formats = %{$c->stash->{'h_formats'}};
	my $query = $c->stash->{'query'};
	my $localpath = '/'.$c->request->path;

	my $cc;

	my $example = 0;
	#my $example = 1;

	my $pdf_export = 0;
	if (exists $c->req->params->{'pdf_export'} and $c->req->params->{'pdf_export'}) {
		$pdf_export = 1;
	}

	my $csv_export = 0;
	if (exists $c->req->params->{'csv_export'} and $c->req->params->{'csv_export'}) {
		$csv_export = 1;
	}

	if ($example) {	# Area example
		$cc = Chart::Clicker->new(width => 500, height => 250);

		my @hours = qw(
				1 2 3 4 5 6 7 8 9 10 11 12
		);
		my @bw1 = qw(
				5.8 5.0 4.9 4.8 4.5 4.25 3.5 2.9 2.5 1.8 .9 .8
		);
		my @bw2 = qw(
				.7 1.1 1.7 2.5 3.0 4.5 5.0 4.9 4.7 4.8 4.2 4.4
		);
		my @bw3 = qw(
				.3 1.4 1.2 1.5 4.0 3.5 2.0 1.9 2.7 4.2 3.2 1.1
		);

		my $series1 = Chart::Clicker::Data::Series->new(
				keys    => \@hours,
				values  => \@bw1,
		);
		my $series2 = Chart::Clicker::Data::Series->new(
				keys    => \@hours,
				values  => \@bw2,
		);

		my $series3 = Chart::Clicker::Data::Series->new(
				keys    => \@hours,
				values  => \@bw3,
		);

		my $ds = Chart::Clicker::Data::DataSet->new(series => [ $series1, $series2, $series3 ]);

		$cc->title->text('Area Chart');
		$cc->title->padding->bottom(5);
		$cc->add_to_datasets($ds);

		my $defctx = $cc->get_context('default');

		my $area = Chart::Clicker::Renderer::Area->new(opacity => .6);
		$area->brush->width(3);
		$defctx->renderer($area);

		$defctx->range_axis->label('Lorem');
		$defctx->domain_axis->label('Ipsum');

		$defctx->renderer->brush->width(2);
	} else {	# Real stuff
		# Parse x and y
		my %xy;

		for my $coord (split(/(?<!\\),/,$conditions{'show'})) {
			$coord =~ s/(?<!\\)\\,//g;
			my ($class, $data_type, $field, $label) = split(/(?<!\\):/,$coord); 
			if (defined $field and $field and defined $class and $class and defined $data_type and $data_type and defined $label and $label) {
				$field =~ s/\\:/:/g;
				$label =~ s/\\:/:/g;
				$xy{$class} = { data_type => $data_type, field => $field, label => $label, column => $field };
			}
		}

		for my $class ('x','y') {
			if (!exists $xy{$class}) {
				$c->stash->{'message'} = "Coordinates for $class axis not found in conditions";
				return 0;
			}
		}
		# check show
		#my $body;
		#for my $key (sort keys %xy) {
		#	$body .= "( $key => data_type $xy{$key}->{data_type}, field $xy{$key}->{field}, label $xy{$key}->{label} ) ";
		#}
		#$c->res->body($body);

		# Data
		# TODO: Series (different conditions)
		my $fields = [];
		my @functions = ();
		my @select = ();
		my @as = ();
		for my $key (sort keys %xy) {
			my $is_func = 0;
			for my $function ("COUNT", "MAX", "MIN", "AVG", "SUM", "BIT_AND", "BIR_OR", "BIT_XOR", "GROUP_CONCAT", "STD", "STDDEV", "STDDEV_POP", "STDDEV_SAMP", "VAR_POP", "VAR_SAMP", "VARIANCE") {
				if ($xy{$key}->{data_type} eq $function) {
					$is_func = 1;
				}
			}
			if ($is_func) {
				push @functions, { $xy{$key}->{data_type} => $xy{$key}->{field} };
				push @select, { $xy{$key}->{data_type} => $xy{$key}->{field}, -as => lc($xy{$key}->{label}) };
				$xy{$key}->{column} = lc($xy{$key}->{label});
			}
			push @select, $xy{$key}->{field};
		}

		# TODO: rangos fechas organizar en días, meses, etc
		my $group_by = $xy{'x'}->{field};

		my $rs;
		my $query_params = {};
		$query_params->{'group_by'} = $conditions{'group_by'} if $conditions{'group_by'};
		$query_params->{'order_by'} = $xy{'x'}->{field};
		$query_params->{'select'} = \@select;
		$query_params->{'as'} = \@as;

		if (@{$fields}) {
			$query_params->{'columns'} = $fields;
			#$query_params->{'columns'} = $conditions{'show'};
		}

		my @series = split(/\s*(?<!\\),\s*/, $conditions{'series_by'});
		my %series;
		my %series_data;
		my $visual = $c->stash->{'visual'};


		if (@series) {
			for my $serie (@series) {
				$series_data{$serie} = {};
				# fetch values for serie
				my %query_params = %{$query_params};
				my $query_params = \%query_params;
				$query_params->{'select'} = $serie;
				$query_params->{'group_by'} = $serie;

				my $rs = $c->model('Asterisk::'.ucfirst($conditions{'table'}))->search($query, $query_params);
				my @values;
				while (my $row = $rs->next) {
					my $value = $row->$serie;
					$c->log->info("Value $value found for serie $serie");
					push @{$series{$serie}}, $value;
				}
			}
		} else {
			push @series, "total";
			$series{'total'} = [ "total" ];
		}

		my (%x,%y,$xlabel,$ylabel);
		my $num_rows;
		for my $serie (@series) {
			$x{$serie} = {};
			$y{$serie} = {};
			for my $value (@{$series{$serie}}) {
				$x{$serie}->{$value} = [];
				$y{$serie}->{$value} = [];
				if ($serie eq "total") {
					$rs = $c->model('Asterisk::'.ucfirst($conditions{'table'}))->search($query, $query_params);
				} else {
					my $query = $query;
					$query = "$serie = '" . $value . "' and (" . $query . ")";
					#$c->log->info(Dumper($query));
					$rs = $c->model('Asterisk::'.ucfirst($conditions{'table'}))->search($query, $query_params);
				}
		
				# Generate arrays for GP
				my (@x,@y,$xlabel,$ylabel);
				$num_rows = 0;
				while (my $row = $rs->next) {
					$num_rows++;
					my $infoline;
					my %column = $row->get_columns;
					for my $key (sort keys %column) {
						$infoline .= " | $key -> $column{$key}";
					}
					$infoline .= " |";
					#$c->log->info($infoline);
					my $xcolumn = $column{$xy{'x'}->{column}};
					my $ycolumn = $column{$xy{'y'}->{column}};
					push @x, $xcolumn;
					push @y, $ycolumn;
		#			$resultline{$key} = $column{$key};
					#$c->log->info("x -> $column{$xy{'x'}->{column}}, y -> $column{$xy{'y'}->{column}}");
				}

				if (!$num_rows) {
					$c->log->info("No results found");
					return 0;
				}

				my $x_date_format = "%Y-%m-%d %T";
				my @group_by = split(/(?<!\\),/, $conditions{'group_by'});
				if ($xy{'x'}->{data_type} eq "date") {
					my $num = 0;
					for my $val (@x) {
						#$val =~ s/ .*//g;
						#$val =~ s/-//g;
						#$val =~ s/..$//g;
						#$val =~ s/-..$/-01 00:00:00/g;
						my $key = $xy{'x'}->{field};
						if ("YEAR($key)" ~~ @group_by or "MONTH($key)" ~~ @group_by) {
							$val =~ s/ .*//;
							if (!("DAY($key)" ~~ @group_by)) {
								$val =~ s/-[^-]+/-01/g;
							} elsif (!("MONTH($key)" ~~ @group_by)) {
								$val =~ s/-[^-]-[^-]+/-01-01/g;
							}
							$val =~ s/$/ 00:00:00/;
						}
						#$val =~ s/ .*$/ 00:00:00/g;
						my $dt = DateTime::Format::MySQL->parse_datetime($val);
						#$c->log->info("DT: " . $dt->epoch);
						#$x[$num] = $val;
						$x[$num] = $dt->epoch;
						#$c->log->info("val x $x[$num], y $y[$num]");
						$num++;
					}
				}

				$x{$serie}->{$value} = \@x;
				$y{$serie}->{$value} = \@y;

				my $series;
				my $title;
				if ($serie eq "total") {
					$title = $c->stash->{'title'};
				} else {
					$title = $serie . " " . $value;
				}
				if ($visual eq "bubble") {
					$series = Chart::Clicker::Data::Series::Size->new(
							keys    => $x{$serie}->{$value},
							values  => $y{$serie}->{$value},
							name		=> $title,
					);
				} else {
					$series = Chart::Clicker::Data::Series->new(
							keys    => $x{$serie}->{$value},
							values  => $y{$serie}->{$value},
							name		=> $title,
					);
				}
				$series_data{$serie}->{$value} = $series;
			}
		}

		$xlabel = $xy{'x'}->{label};
		$ylabel = $xy{'y'}->{label};

		# Define graph
		my ($width, $height) = (650, 350);
		$width = $formats{'width'} if (exists $formats{'width'});
		$height = $formats{'height'} if (exists $formats{'height'});
		$cc = Chart::Clicker->new(width => $width, height => $height);
		


		#my $axis = Chart::Clicker::Axis->new({
		#	label_font  => Graphics::Primitive::Font->new,
		#	orientation => 'vertical',
		#	position => 'left',
		#	brush => Graphics::Primitive::Brush->new,
		#	visible => 1,
		#});

		#my $series1;
		#if ($visual eq "bubble") {
			#$series1 = Chart::Clicker::Data::Series::Size->new(
					#keys    => $x,
					#values  => $y,
					#name		=> $c->stash->{'title'},
			#);
		#} else {
			#$series1 = Chart::Clicker::Data::Series->new(
					#keys    => $x,
					#values  => $y,
					#name		=> $c->stash->{'title'},
			#);
		#}
		#my $series2 = Chart::Clicker::Data::Series->new(
				#keys    => \@hours,
				#values  => \@bw2,
		#);

		#my $series3 = Chart::Clicker::Data::Series->new(
				#keys    => \@hours,
				#values  => \@bw3,
		#);

		#my $ds = Chart::Clicker::Data::DataSet->new(series => [ $series1, $series2, $series3 ]);
		#my $ds = Chart::Clicker::Data::DataSet->new(series => [ $series1 ]);
		my $ds = Chart::Clicker::Data::DataSet->new;
		for my $serie (keys %series_data) {
			for my $value (keys %{$series_data{$serie}}) {
				$c->log->info("Adding $serie $value to DataSet");
				$ds->add_to_series($series_data{$serie}->{$value});
			}
		}

		#$cc->title->text('Area Chart');
		if ($pdf_export) {
			$cc->title->text($c->stash->{'title'});
		}
		$cc->title->padding->bottom(5);
		$cc->add_to_datasets($ds);

		my $defctx = $cc->get_context('default');

		my $chart;
		$c->log->info("VISUAL: $visual");
		if ($visual eq "area") {
			$chart = Chart::Clicker::Renderer::Area->new(opacity => .6);
		} elsif ($visual eq "bar") {
			$chart = Chart::Clicker::Renderer::Bar->new(opacity => .6);
		} elsif ($visual eq "bubble") {
			$chart = Chart::Clicker::Renderer::Bubble->new;
		} elsif ($visual eq "candlestick") {
			$chart = Chart::Clicker::Renderer::CandleStick->new(opacity => .6);
		} elsif ($visual eq "line") {
			$chart = Chart::Clicker::Renderer::Line->new(opacity => .6);
		} elsif ($visual eq "pie") {
			$chart = Chart::Clicker::Renderer::Pie->new(opacity => .6);
			$chart->brush->width(3);
			$chart->border_color(Graphics::Color::RGB->new(red => 1, green => 1, blue => 1));
		} elsif ($visual eq "point") {
			$chart = Chart::Clicker::Renderer::Point->new(opacity => .6);
		} elsif ($visual eq "polararea") {
			$chart = Chart::Clicker::Renderer::PolarArea->new(opacity => .6);
		} elsif ($visual eq "stackedarea") {
			$chart = Chart::Clicker::Renderer::StackedArea->new(opacity => .6);
		} elsif ($visual eq "stackedbar") {
			$chart = Chart::Clicker::Renderer::StackedBar->new(opacity => .6);
		}
		if ($visual eq "area" or $visual eq "bar" or $visual eq "line" or $visual eq "stackedarea" or $visual eq "stackedbar") {
			$chart->brush->width(1);
		}
		$defctx->renderer($chart);

		$defctx->domain_axis->label($xlabel);
		$defctx->range_axis->label($ylabel);
		$defctx->range_axis->format("%.0d");

		if ($visual eq "area" or $visual eq "bar" or $visual eq "line" or $visual eq "stackedarea" or $visual eq "stackedbar") {
			$defctx->renderer->brush->width(1);
		}

		my $font = Graphics::Primitive::Font->new(
													family	=> 'Arial',
													size		=> '10',
													slant		=> 'normal',
		);


		my $ticks = 20;
		if ($num_rows < $ticks) {
			$ticks = $num_rows;
		}
		$c->log->info("ticks: $ticks");
		if ($visual eq "pie") {
			$defctx->domain_axis->hidden(1);
			$defctx->range_axis->hidden(1);
			$cc->plot->grid->visible(0);
		} else {
			$defctx->domain_axis(
				Chart::Clicker::Axis::DateTime->new(
					position		=> 'bottom',
					orientation	=> 'horizontal',
					# FIXME: Valores ticks configurable?
					ticks				=> $ticks,
					format			=> "%Y-%m-%d",
					# label_font	=> $font,
					#	label_font  => Graphics::Primitive::Font->new,
					#	orientation => 'vertical',
					#	position => 'left',
					#	brush => Graphics::Primitive::Brush->new,
					#	visible => 1,
				)
			);
			$defctx->domain_axis->tick_font($font);
			$defctx->range_axis->tick_font($font);
			$defctx->domain_axis->tick_label_angle(-1.22);	# Angle in radians
		}
	}

	my $current_view = 'GP';
	if ($pdf_export) {
		$current_view = 'GP_PDF';
	}

	my %chart_data = %{$cc};
	$DB::single=1;	# Debug info: Some modules need it
	$c->stash( graphics_primitive => $cc,
						 current_view				=> $current_view );
}

sub stat_show_list :Private {
	my ($self, $c) = @_;
	my ($stat, $page) = ($c->stash->{'stat'}, $c->stash->{'page'});

	my %conditions = %{$c->stash->{'h_conditions'}};
	my %formats = %{$c->stash->{'h_formats'}};
	my $query = $c->stash->{'query'};
	my $title_rows_per_page = $c->stash->{'title_rows_per_page'};
	if (!defined $title_rows_per_page) {
		$title_rows_per_page = "Rows per page";
	}

	my $pdf_export = "";
	if (exists $c->req->params->{'pdf_export'} and $c->req->params->{'pdf_export'}) {
		$pdf_export = $c->req->params->{'pdf_export'};
	}

	my $csv_export = "";
	if (exists $c->req->params->{'csv_export'} and $c->req->params->{'csv_export'}) {
		$csv_export = $c->req->params->{'csv_export'};
	}

	my @columns;
	if (exists $conditions{'show'}) {
		$conditions{'show'} =~ s/(?<!\\),/ /g;
		@columns = split (/(?<!\\)\s+/, $conditions{'show'});
	}

	my $rows_per_page = 1000000000000;
	if (!$pdf_export and !$csv_export) {
		if (defined $title_rows_per_page and exists $c->req->params->{$title_rows_per_page}) {
			$rows_per_page = $c->req->params->{$title_rows_per_page};
		} elsif ($formats{'rows_per_page'}) {
			$rows_per_page = $formats{'rows_per_page'};
		}
		if (defined $rows_per_page and $rows_per_page) {
			$c->log->info("Paginating results in $rows_per_page rows per page");
		} else {
			$rows_per_page = 0;
		}
	}

	$c->log->info("QUERY: $query") if (defined $query);

	# Query

	# series en show
	my @series_by;
	if (exists $conditions{'series_by'}) {
		my $series_by = $conditions{'series_by'};
		@series_by = split(/\s*(?<!\\),\s*/, $series_by);
		for my $serie (@series_by) {
			push (@columns, $serie) if (not $serie ~~ @columns);
		}
	}
	my @columns_tmp = @columns;
	my @select;
	my @as;
	@columns = ();
	my @template_columns;
	my @functions;
	while (my $column = shift @columns_tmp) {
		my $is_func = 0;
		if ($column =~ m/^([xy]):(.*):(.*):(.*)/) {
			my ($axis,$type,$field,$label) = ($1,$2,$3,$4);
			$c->log->info("$axis..$type..$field..$label");
			for my $function ("COUNT", "MAX", "MIN", "AVG", "SUM", "BIT_AND", "BIR_OR", "BIT_XOR", "GROUP_CONCAT", "STD", "STDDEV", "STDDEV_POP", "STDDEV_SAMP", "VAR_POP", "VAR_SAMP", "VARIANCE") {
				if ($type eq $function) {
					$c->log->info("Function detected $label: $type($field)");
					$is_func = 1;
				}
			}
			if ($is_func) {
				push @functions, { $type => $field };
				$label =~ s/ /_/g;
				push @select, { $type => $field, -as => lc($label) };
				push @template_columns, lc($label) if (!(lc($label) ~~ @template_columns));
				$conditions{'group_by'} =~ s/$type\($field\)\s+,/$label/g;
			}
			push @select, $field;
			push @template_columns, $field if (!($field ~~ @template_columns));
			$c->log->info("XY COLUMN: $column");
		} elsif ($column =~ m/(.*)\((.*)\)/) {
			my ($function, $params) = ($1, $2);
			#push @columns, $params;
			#push @functions, { $function, $params };
			my $as = lc($function . "_" . $params);
			push @select, { $function => $params, -as => $as };
			#push @columns, $params;
			push @template_columns, $as if (!($as ~~ @template_columns));
			$c->log->info("FUNC COLUMN: $column");
		} else {
			push @columns, $column;
			push @template_columns, $column if (!($column ~~ @template_columns));
			#push @select, $column;
			#push @as, $column;
			$c->log->info("COLUMN: $column");
		}
	}
	my $group_by = $conditions{'group_by'};
	$group_by = "" if (!defined $group_by);
	my @group_by = split(/\s*(?<!\\),\s*/, $group_by);
	if (exists $conditions{'series_by'}) {
		my @group_by_fixed;
		for my $serie (@series_by) {
			while (my $group_by = shift(@group_by)) {
				if ($group_by ne $serie) {
					push @group_by_fixed, $group_by;
				}
			}
			unshift @group_by_fixed, $serie;
		}
		@group_by = @group_by_fixed;
	}
	my @tmp_group_by = @group_by;
	@group_by = ();
	for my $group_by (@tmp_group_by) {
		if ($group_by =~ m/(.*)\((.*)\)/) {
			my ($func,$field) = ($1,$2);
			my $as = lc($func . "_" . $field);
			push @select, { $func => $field, -as => $as };
			push @group_by, $as;
		} else {
			push @group_by, $group_by;
		}
	}
	$c->stash->{'template_columns'} = \@template_columns;
	$c->log->info("template_columns: " . join(",",@template_columns));
	
	my $rs;
	my $query_params = {};
	$query_params->{'group_by'} = \@group_by;
	$query_params->{'order_by'} = $conditions{'order_by'} if $conditions{'order_by'};

	if (@columns) {
		$query_params->{'columns'} = \@columns;
		#$query_params->{'columns'} = $conditions{'show'};
		$c->log->info("Query columns: ".join("|",@columns));
	}

	if (@select) {
		$query_params->{'select'} = \@select;
		$c->log->info("Select:\n".Dump(@select));
	}

	$query_params->{'page'} = $page if $page;
	$query_params->{'rows'} = $rows_per_page if $rows_per_page;

	# Fix table name
	my $table = $conditions{'table'};
	my @table_words = split(/[_ ]+/, $table);
	my @table_words_fixed;
	$table = "";
	for my $word (@table_words) {
		$table .= ucfirst($word);
	}
	$rs = $c->model('Asterisk::'.$table)->search($query, $query_params);
	
	my $localpath = '/'.$c->request->path;

	# paging
	my $pager = $rs->pager();
	if ($rows_per_page) {
		my $first_page = $pager->first_page;
		my $last_page = $pager->last_page;
		if ($page > $first_page) {
			my $prev_page = $page - 1;
			$c->stash->{'prev_page'} = $prev_page;
			my $prev_page_uri = $localpath;
			$prev_page_uri =~ s/[0-9]+$/$prev_page/;
			$c->stash->{'prev_page_uri'} = $prev_page_uri;
			my $first_page_uri = $localpath;
			$first_page_uri =~ s/[0-9]+$/$first_page/;
			$c->stash->{'first_page_uri'} = $first_page_uri;
		}
		if ($page < $last_page) {
			my $next_page = $page + 1;
			$c->stash->{'next_page'} = $next_page;
			my $next_page_uri = $localpath;
			$next_page_uri =~ s/[0-9]+$/$next_page/;
			$c->stash->{'next_page_uri'} = $next_page_uri;
			my $last_page_uri = $localpath;
			$last_page_uri =~ s/[0-9]+$/$last_page/;
			$c->stash->{'last_page_uri'} = $last_page_uri;
		}
		my $prev_20_page;
		if ($page - 20 > $first_page) {
			$prev_20_page = $page - 20;
		} else {
			$prev_20_page = $first_page;
		}
		$c->stash->{'prev_20_page'} = $prev_20_page;
		my $prev_20_page_uri = $localpath;
		$prev_20_page_uri =~ s/[0-9]+$/$prev_20_page/;
		$c->stash->{'prev_20_page_uri'} = $prev_20_page_uri;
		my $next_20_page;
		if ($page + 20 < $last_page) {
			$next_20_page = $page + 20;
		} else {
			$next_20_page = $last_page;
		}
		$c->stash->{'next_20_page'} = $next_20_page;
		my $next_20_page_uri = $localpath;
		$next_20_page_uri =~ s/[0-9]+$/$next_20_page/;
		$c->stash->{'next_20_page_uri'} = $next_20_page_uri;
		$c->stash->{'first_entry'} = $pager->first;
		$c->stash->{'last_entry'} = $pager->last;
		$c->stash->{'total_entries'} = $pager->total_entries;
		$c->stash->{'current_page'} = $pager->current_page;
		$c->stash->{'first_page'} = $first_page;
		$c->stash->{'last_page'} = $last_page;
	}

	#@{$c->stash->{'result'}} = $rs->all;

	my @result;
	while (my $row = $rs->next) {
		my $infoline;
		my %column = $row->get_columns;
		my %resultline;
		for my $key (sort keys %column) {
			my $data = "";
			$data = $column{$key} if (exists $column{$key} and $column{$key});
			$infoline .= " | $key -> $data";
			$resultline{$key} = $data;
			if ("year_$key" ~~ @group_by) {
				$resultline{$key} =~ s/ .*//;
				if (!("day_$key" ~~ @group_by)) {
					$resultline{$key} =~ s/-[^-]+$//g;
				} elsif (!("month_$key" ~~ @group_by)) {
					$resultline{$key} =~ s/-[^-]+$//g;
				}
			}
		}
		push @result, \%resultline;
		$infoline .= " |";
		$c->log->info($infoline);
	}
	$c->stash->{'result'} = \@result;

	for my $key (keys %{$c->req->params}) {
		$c->log->info("KEY $key");
		push @{$c->stash->{'param_keys'}}, $key;
	}

	if (!$c->stash->{'graph'} and !$pager->last) {
		$c->stash->{'message'} = "No results found";
		$c->stash->{'no_results_found'} = 1;
	} elsif ($pdf_export or $csv_export) {
		my $template = $c->stash->{'template'};
		$c->log->info("Template: ". $template);
		$c->stash->{'no_logo'} = 1;
		$c->stash->{'no_navbar'} = 1;
		$c->stash->{'no_buttons'} = 1;
		$c->stash->{'no_page'} = 1;
		if ($pdf_export) {
			$c->stash->{wk} = {
				template    => $template,
				page_size   => 'a4',
			};
			$c->stash( current_view				=> 'Wkhtmltopdf' );
		} elsif ($csv_export) {
			$c->res->headers->header('Content-Type' => 'text/csv');
			my $filename = $c->stash->{'title'};
			$filename =~ s/\s/_/g;
			$filename =~ tr/A-Z/a-z/;
			$filename =~ s/$/.csv/;
			$c->res->headers->header('Content-Disposition' => "attachement;filename=$filename");
			my $csv = Class::CSV->new(
				fields					=> \@template_columns,
				line_separator	=> "\r\n",
			);
			while (my $reg = shift @result) {
				my $reg_data = {};
				for my $column (@template_columns) {
					$reg_data->{$column} = $reg->{$column};
					#$c->log->info("reg_data $column -> $reg->{$column}");
				}
				$csv->add_line($reg_data);
			}
			$c->res->body($csv->string());
		}
	}
}

sub queuelogvirt_test :Chained :Path("/queuelogvirt_test") :Args(0) {
	my ($self, $c) = @_;

	#$c->stash->{'template'} = "stats/queuelogvirt_test_2.tt";
	$c->stash->{'template'} = "stats/queuelogvirt_list.tt";

	my $model = $c->model('Asterisk::QueueLog');
	my $qlogvirt = $c->model('QueueLogVirt')->new(show => "wait_time,max_call_duration,calls_answered,calls", series_by => "agent,call", date_from => "1995-01-01", date_to => "2012-12-31");

	$c->log->info("QLOGVIRTMSG: ".$qlogvirt->msg);
	$c->stash->{'qlogvirt'} = $qlogvirt;
	@{$c->stash->{'rs'}} = $qlogvirt->resultset->all;

	$c->stash->{'series'} = $qlogvirt->series;
	$c->stash->{'values'} = $qlogvirt->values;
	$c->stash->{'keys'} = $qlogvirt->keys;
	$c->stash->{'result'} = $qlogvirt->result;

	$c->log->info("Series: ".join(",",@{$qlogvirt->series}));

	for my $serie (@{$qlogvirt->series}) {
		for my $value (@{$qlogvirt->values->{$serie}}) {
			$c->log->info("$serie $value:");
			for my $key (@{$qlogvirt->keys}) {
				$c->log->info("$key => ".$qlogvirt->result->{$serie}->{$value}->{$key});
			}
		}
	}
}

sub queuelogvirt_list :Private {
	my ($self, $c) = @_;

	my %conditions = %{$c->stash->{'h_conditions'}};
	my %formats = %{$c->stash->{'h_formats'}};
	my $query = $c->stash->{'query'};
	my $model = $c->model('Asterisk::QueueLog');

	$c->stash->{'template'} = "stats/queuelogvirt_list.tt";

	my $pdf_export = "";
	if (exists $c->req->params->{'pdf_export'} and $c->req->params->{'pdf_export'}) {
		$pdf_export = $c->req->params->{'pdf_export'};
	}

	my $csv_export = "";
	if (exists $c->req->params->{'csv_export'} and $c->req->params->{'csv_export'}) {
		$csv_export = $c->req->params->{'csv_export'};
	}

	for my $key (keys %{$c->req->params}) {
		$c->log->info("KEY $key");
		push @{$c->stash->{'param_keys'}}, $key;
	}

	my %params;

	my $show = $conditions{show};
	$params{show} = $show if (defined $show and $show);
	my $series_by = $conditions{series_by};
	$params{series_by} = $series_by if (defined $series_by and $series_by);

	# date_from y to
	my $date_from;
	my $date_to;
	if (exists $conditions{'date_from'} and $conditions{'date_from'}) {
		my $date_from_cond = $conditions{'date_from'};
		$date_from_cond =~ m/(?<!\\)#([^#]+)(?<!\\)#([^#]+)(?<!\\)#/;
		my $date_from_param = $2;
		$date_from = $c->req->params->{$date_from_param};
	}
	if (exists $conditions{'date_to'} and $conditions{'date_to'}) {
		my $date_to_cond = $conditions{'date_to'};
		$date_to_cond =~ m/(?<!\\)#([^#]+)(?<!\\)#([^#]+)(?<!\\)#/;
		my $date_to_param = $2;
		$date_to = $c->req->params->{$date_to_param};
	}
	$params{date_from} = $date_from if (defined $date_from and $date_from);
	$params{date_to} = $date_to if (defined $date_to and $date_to);
	$c->log->info("Date from: $params{date_from}, Date to: $params{date_to}");

	my $qlogvirt = $c->model('QueueLogVirt')->new(%params);

	$c->log->info("QLOGVIRTMSG: ".$qlogvirt->msg);
	$c->stash->{'qlogvirt'} = $qlogvirt;
	@{$c->stash->{'rs'}} = $qlogvirt->resultset->all;

	$c->stash->{'series'} = $qlogvirt->series;
	$c->stash->{'values'} = $qlogvirt->values;
	$c->stash->{'keys'} = $qlogvirt->keys;
	$c->stash->{'result'} = $qlogvirt->result;

	$c->log->info("Series: ".join(",",@{$qlogvirt->series}));

	for my $serie (@{$qlogvirt->series}) {
		for my $value (@{$qlogvirt->values->{$serie}}) {
			$c->log->info("$serie $value:");
			for my $key (@{$qlogvirt->keys}) {
				$c->log->info("$key => ".$qlogvirt->result->{$serie}->{$value}->{$key});
			}
		}
	}

	if ($pdf_export or $csv_export) {
		my $template = $c->stash->{'template'};
		$c->log->info("Template: ". $template);
		$c->stash->{'no_logo'} = 1;
		$c->stash->{'no_navbar'} = 1;
		$c->stash->{'no_buttons'} = 1;
		$c->stash->{'no_page'} = 1;
		if ($pdf_export) {
			$c->stash->{wk} = {
				template    => $template,
				page_size   => 'a4',
			};
			$c->stash( current_view				=> 'Wkhtmltopdf' );
		} elsif ($csv_export) {
			$c->res->headers->header('Content-Type' => 'text/csv');
			my $filename = $c->stash->{'title'};
			$filename =~ s/\s/_/g;
			$filename =~ tr/A-Z/a-z/;
			$filename =~ s/$/.csv/;
			my @columns = @{$qlogvirt->keys};
			unshift @columns, "Serie";
			$c->res->headers->header('Content-Disposition' => "attachement;filename=$filename");
			my $csv = Class::CSV->new(
				fields					=> \@columns,
				line_separator	=> "\r\n",
			);
			# $qlogvirt->result->{$serie}->{$value}->{$key};
			for my $serie (keys %{$qlogvirt->result}) {
				for my $value (keys %{$qlogvirt->result->{$serie}}) {
					my $reg_data = {};
					if ($serie eq "total") {
						$reg_data->{'Serie'} = "Total";
					} else {
						$reg_data->{'Serie'} = "$serie $value";
					}
					for my $key (keys %{$qlogvirt->result->{$serie}->{$value}}) {
						$reg_data->{$key} = $qlogvirt->result->{$serie}->{$value}->{$key};
					}
					$csv->add_line($reg_data);
				}
			}
			$c->res->body($csv->string());
		}
	}
}

sub stat_show :Chained :Path("/stats/exec") :Args(2) {
	my ($self, $c, $stat, $page) = @_;

	$c->stash->{'template'} = "stats/exec_list.tt";

	$c->stash->{'stat'} = $stat;
	$c->stash->{'page'} = $page;

	my $pdf_export = 0;
	if (exists $c->req->params->{'pdf_export'} and $c->req->params->{'pdf_export'}) {
		$pdf_export = 1;
		$c->stash->{'pdf_export'} = 1;
	}

	my $stat_row = $c->model('Astatistics::Stat')->find($stat);

	if (!$stat_row) {
		$c->stash->message("Stat id $stat could not be retrieved");
		return 0;
	}

	my ($name, $visual, $conditions, $formats) = ($stat_row->name, $stat_row->visual, $stat_row->conditions, $stat_row->format);

	$name =~ s/\n//g;
	$visual =~ s/\n//g;
	$conditions =~ s/\n//g;
	$formats =~ s/\n//g;

	$c->stash->{'name'} = $name;
	$c->stash->{'visual'} = $visual;
	$c->stash->{'conditions'} = $conditions;
	$c->stash->{'format'} = $formats;

	my %conditions;
	# Parse conditions
	for my $condition (split (/\s*(?<!\\);\s*/, $conditions)) {
		$condition =~ s/\\;/;/g;
		$condition =~ m/([^=]+)\s*=\s*(.*)/;
		my ($key, $value) = ($1, $2);
		if (defined $key and defined $value and $key) {
			$conditions{$key} = $value;
			$c->log->info("$key -> $conditions{$key}");
		}
	}
	my @req_conditions = ("table");

	# Parse format
	my %formats;
	for my $format (split (/\s*(?<!\\);\n?\s*/, $formats)) {
		my ($key, $value) = split /\s*(?<!\\)=\s*/, $format;
		if (defined $key and defined $value and $key) {
			$formats{$key} = $value;
			#$c->log->info("$key -> $formats{$key}");
		}
	}

	my @missing_reqs;
	for my $req_condition (@req_conditions) {
		if (!exists($conditions{$req_condition})) {
			push @missing_reqs, $req_condition;
		}
	}
	if (@missing_reqs) {
		$c->stash->{'message'} = "Error parsing stat conditions: missing required conditions ".join(",",@missing_reqs);
		$c->stash->{'template'} = "stats/exec_error.tt";
		return 0;
	}

	# Variable parameters
	my @params;
	my %param_class;
	my %param_params;
	my %param_params_checked;

	my @datepicker_header_code;

	my $where = "";
	if (exists $conditions{'table'} and ($conditions{'table'} eq 'queuelog_virt' or $conditions{'table'} eq 'queue_log_virt')) {
		$where = $conditions{'where'} if (defined $conditions{'where'} and $conditions{'where'});
		if ((exists $conditions{'date_from'} and $conditions{'date_from'}) or (exists $conditions{'date_to'} and $conditions{'date_to'})) {
			$where .= "XXXDATESQLOGVIRTXXX";
			$where .= $conditions{'date_from'} if (exists $conditions{'date_from'});
			$where .= $conditions{'date_to'} if (exists $conditions{'date_to'});
		}
	} else {
		$where = $conditions{'where'} if (exists $conditions{'where'} and $conditions{'where'});
	}
	if ($where) {
		$c->log->info("where -> $where");
		while ($where =~ m/(?<!\\)#([^#]+)(?<!\\)#([^#]+)(?<!\\)#/g) {
			my ($param_class, $param_name_params) = ($1, $2);
			$param_class =~ s/\\#/#/g;
			$param_name_params =~ s/\\#/#/g;
			my ($param_name, $param_params, @param_params, @param_params_tmp);
			if ($param_name_params =~ m/(.*)\((.*)\)/) {
				($param_name, $param_params) = ($1, $2);
				@param_params_tmp = split(/(?<!\\)\|/, $param_params);
				$param_params_checked{$param_name} = {};
			} else {
				($param_name, $param_params) = ($param_name_params,'');
			}
			if (! ($param_name ~~ @params)) {
				$c->log->info("Found new param '$param_name' class '$param_class' with params: " . join(", ",@param_params_tmp));
				push @params, $param_name;
				$param_class{$param_name} = $param_class;
				# checked for checkboxes or radio
				for my $param_opt (@param_params_tmp) {
					$param_opt =~ m/(?<!\\)(--checked)$/;
					my $checked = $1;
					$param_opt =~ s/--checked$//;
					push @param_params, $param_opt;
					# Default or already set params for checkboxes and radios
					if ( ($param_class eq "radio" and $c->req->params->{$param_name} eq $param_opt)
							 or ($param_class eq "checkbox" and $c->req->params->{$param_name . ":" . $param_opt})
							 or ( !$c->req->params->{'params_done_before'}
										and defined $checked and $checked eq "--checked"
										and	($param_class eq "checkbox"
												or ($param_class eq "radio" and !$c->req->params->{$param_name})
												)
									)
						 ) {
						$param_params_checked{$param_name}->{$param_opt} = 1;
						$c->log->info("Option '$param_opt' for param '$param_name' checked");
					} else {
						$c->log->info("Option '$param_opt' for param '$param_name' not checked");
					}
				}
				$param_params{$param_name} = \@param_params;
				if ($param_class eq "date" or $param_class eq "datetime") {
					push (@datepicker_header_code, '
						new JsDatePick({
							useMode:2,
							isStripped:false,
							dateFormat:"%Y-%m-%d",
							limitToToday:false,
							weekStartDay:1,
							cellColorScheme:"aqua",
							imgPath:"/static/jsdatepicker/img/",
							target:"'.$param_name.'"
						});
					');
				}
			}
		}
	}

	# Title
	my $title = $c->req->params->{'name'};
	if ($formats{'title'}) {
		$title = $formats{'title'};
		my $titletmp = $title;
		while ($title =~ m/(?<!\\)#([^#]+)(?<!\\)#([^#]+)(?<!\\)#/g) {
			my ($type,$param) = ($1,$2);
			$c->log->info("Title $1 $2");
			my $param_value = $c->req->params->{$param};
			$titletmp =~ s/#$1#$2#/$param_value/;
		}
		$title = $titletmp;
	}
	$c->stash->{'title'} = $title;

	my $title_rows_per_page;
	if (exists $formats{'rows_per_page'} and !$c->stash->{'graph'}) {
		while ($formats{'rows_per_page'} =~ m/(?<!\\)#([^#]+)(?<!\\)#([^#]+)?(?<!\\)#?/g) {
			my ($title, $default) = ($1,$2);
			push (@params,$title);
			$title_rows_per_page = $title;
			$param_class{$title} = "text";
			$default = "20" if !$default;
			$c->req->params->{"$title"} = $default if (!$c->req->params->{"$title"});
		}
	}

	my $title_refresh;
	if (exists $conditions{'refresh'}) {
		if ($conditions{'refresh'} =~ /(?<!\\)#([^#]+)(?<!\\)#([^#]+)?(?<!\\)#?/) {
			while ($conditions{'refresh'} =~ m/(?<!\\)#([^#]+)(?<!\\)#([^#]+)?(?<!\\)#?/g) {
				my ($title, $default) = ($1,$2);
				push (@params,$title);
				$title_refresh = $title;
				$param_class{$title} = "text";
				$default = "5" if !$default;
				$c->req->params->{"repeat"} = 1 if !$c->req->params->{"$title"};
				$c->req->params->{"$title"} = $default if (!$c->req->params->{"$title"});
				$c->stash->{refresh} = $c->req->params->{"$title"};
			}
		} else {
			$c->stash->{refresh} = $conditions{'refresh'};
		}
	}

	$c->stash->{'params'} = \@params;
	$c->stash->{'param_class'} = \%param_class;
	$c->stash->{'param_params'} = \%param_params;
	$c->stash->{'param_params_checked'} = \%param_params_checked;

	my $params_ok = 1;
	my $query = $conditions{'where'} if (defined $conditions{'where'});
	my $first;

	for my $param (@params) {
		if ((!$c->req->params->{$param} and $param_class{$param} ne "checkbox") or $c->req->params->{'repeat'}) {
			$params_ok = 0;
			$c->stash->{'template'} = "stats/exec_get_params.tt";

			if ($param_class{$param} eq "date" or $param_class{$param} eq "datetime") {
				# jsdatepicker code
				$c->stash->{'jsdatepicker_header'} = '
					<link rel="stylesheet" type="text/css" media="all" href="/static/jsdatepicker/jsDatePick_ltr.css" />
					<script type="text/javascript" src="/static/jsdatepicker/jsDatePick.full.1.3.js"></script>
					<script type="text/javascript">
						window.onload = function(){
	';
				for my $code (@datepicker_header_code) {
					$c->stash->{'jsdatepicker_header'} .= $code;
				}
			
				$c->stash->{'jsdatepicker_header'} .= '
						};
					</script>
	';
				if (!$c->req->params->{$param}) {
					my $now = DateTime->now->datetime;
					if ($param_class{$param} eq "date") {
						$now =~ s/T.*//g;
					} elsif ($param_class{$param} eq "datetime") {
						$now =~ s/T/ /g;
					}
					$c->req->params->{$param} = $now;
				}
			}
		} else {
			my $param_input = "";
			$query =~ m/([^\s]+\s+[^\s]+\s+)(?<!\\)#$param_class{$param}#($param)(|\([^#()]*\))(?<!\\)#/ if (defined $query);
			my $pre = $1;
			if ($param_class{$param} eq "checkbox") {
				my $first_option = 1;
				for my $option (@{$param_params{$param}}) {
					if ($c->req->params->{$param . ":" . $option} or ($param_class{$param} eq "radio" and $c->req->params->{$param})) {
						$c->log->info("Value $option checked for $param");
						if (!$first_option) {
							$param_input .= " or ";
						} else {
							$param_input .= "(";
							$first_option = 0;
						}
						$pre = "" if (!defined $pre);
						$param_input .= "$pre'$option'";
					} else {
						$c->log->info("Value $option not checked for $param");
					}
				}
				if ($param_input) {
					$param_input .= ")";
				}
			} else {
				my $value = $c->req->params->{$param};
				$c->log->info("Param '$param' has value '$value'");
				$pre = "" if (!defined $pre);
				$param_input = "$pre'$value'";
			}
			$pre = "" if (!defined $pre);
			if ($param_input) {
				if ($param_class{$param} eq "date") {
					$c->log->info("Date detected for param $param");

					# date = value put hours with < and >
					# date < value or date <= value and with > and >= put hour
					if ($pre =~ />=?\s*$/) {
						$param_input =~ s/'$/ 00:00:00'/;
					} elsif ($pre =~ /<=?\s*$/) {
						$param_input =~ s/'$/ 23:59:59'/;
					} elsif ($pre =~ /\s+=\s*$/) {
						my $val = $param_input;
						$val =~ s/^[^']+'//;
						$val =~ s/'$//;
						my $pre_without_equal_sign = $pre;
						$pre_without_equal_sign =~ s/=\s*$//;
						$param_input = "($pre_without_equal_sign > '$val 00:00:00' and $pre_without_equal_sign < '$val 23:59:59')";
					} else {
						$query =~ s/$pre(?<!\\)#$param_class{$param}#($param)(|\([^#()]*\))(?<!\\)#/$param_input/g if (defined $query);
					}
				}
				$query =~ s/$pre(?<!\\)#$param_class{$param}#($param)(|\([^#()]*\))(?<!\\)#/$param_input/g if (defined $query);
			} else {
				$query =~ s/$pre(?<!\\)#$param_class{$param}#($param)(|\([^#()]*\))(?<!\\)#/1/g if (defined $query);
			}
			#$c->log->info("Query is '$query' now");
			if ($first) {
				$first = 0;
			}
		}
	}

	if (!$params_ok) {
		$c->stash->{'refresh'} = "";	# No refresh when asking for params
		return 0;
	}

	$c->stash->{'stat'} = $stat;
	$c->stash->{'page'} = $page;
	$c->stash->{'title_rows_per_page'} = $title_rows_per_page;
	$c->stash->{'h_conditions'} = \%conditions;
	$c->stash->{'h_formats'} = \%formats;
	$c->stash->{'query'} = $query;

	$c->log->info("Visual: $visual");
	if ($visual eq "list") {
		if ($conditions{'table'} eq "queuelog_virt" or $conditions{'table'} eq "queue_log_virt") {
			$c->detach("queuelogvirt_list");
		} else {
			$c->detach("stat_show_list");
		}
	} elsif ($visual eq "bar" or $visual eq "line" or $visual eq "area" or $visual eq "pie" or $visual eq "bubble" or $visual eq "point" or $visual eq "polararea" or $visual eq "candlestick") {
		if ($c->req->params->{'do_chart'}) {
			$c->detach("stat_show_gp");
		} else {
			$c->log->info("path: ".$c->request->path);
			my $params = $c->req->params;
			my $gp_uri = "/" . $c->request->path;
			if (@params) {
				$gp_uri .= "?";
				my $first = 1;
				for my $param (keys %{$params}) {
					my $value = $c->req->params->{$param};
					$param =~ s/ /%20/g;
					$value =~ s/ /%20/g;
					if (!$first) {
						$gp_uri .= "&";
					} else {
						$first = 0;
					}
					$gp_uri .= "$param=$value";
				}
				$gp_uri .= "&do_chart=1";
				$c->stash->{'gp_uri'} = $gp_uri;
			}
			$c->stash->{'template'} = 'stats/exec_gp.tt';
		}
	}
}

sub set_position :Private {
	my ($self, $c) = @_;

	my $action = $c->stash->{'action'};
	my $class = $c->req->params->{'class'};
	my $id = $c->req->params->{'id'};

	$c->log->info("Action: $action, $class id $id");

	# Down implica position++, comprobar nueva position si está ocupada y
	# en caso afirmativo intercambiar. En caso contrario mover superiores hacia
	# abajo para eliminar el hueco.
	#
	# Up implica position-- y lo mismo pero al revés.
	# 
	# Para arreglar comprobar count de entradas en número destino y mover todas ellas
	# para dejar hueco para la nueva (arreglando espacios superiores).
	
	my $rs;
	my $model_name;
	my $parent_field;
	my $id_field;
	if ($class eq "group") {
		$model_name = "StGroupsToStGroup";
		$parent_field = "parent_group_id";
		$id_field = "group_id";
	} elsif ($class eq "template") {
		$model_name = "StatsToStGroup";
		$parent_field = "group_id";
		$id_field = "stat_id";
	}
	my $parent = $c->req->params->{'parent'};
	if (!defined $parent or !$parent) {
		$parent = 0;
	}
	my $model = ('Astatistics::'.$model_name);
	$c->log->info("MODEL: $model, $parent_field => $parent, $id_field => $id");
	$rs = $c->model($model)->search({
							-and => [
												{ $parent_field => $parent },
												{ $id_field => $id }
											]
						});

	my $row = $rs->next;
	my $position = $row->position;
	if (!defined $position or !$position) {
		$position = 0;
	}

	$c->log->info("Position: $position");

	my $new_pos = $position;
	my $up = 0;
	if ($action =~ /_up$/) {
		$c->log->info("Action: UP");
		$up = 1;
		if ($new_pos) {	# not for 0
			$new_pos--;
		}
	} else {
		$c->log->info("Action: DOWN");
		$new_pos++;
	}

	my $rs_samepos = $c->model($model)->search({
							-and => [
												{ $parent_field => $c->req->params->{'parent'} },
												{ $id_field => { "<>" => $id } },
												{ position => $new_pos }
											]
										});
	my $correct_new = 0;
	while (my $row = $rs_samepos->next) {
		$c->log->info("Updating position for id ".$row->id." to $position");
		$row->position($position);
		if (!$row->update) {
			$c->log->info("Could not update position for id ".$row->id." to $position");
		}
		if ($up) {
			$position++;
		} else {
			$new_pos++;
			$position++;
		}
	}

	if (! $up) {
		$new_pos--;
	}

	# Update position for the moved object
	$c->log->info("Updating position for id ".$row->id." to $new_pos");
	$row->position($new_pos);
	if (!$row->update) {
		$c->log->info("Could not update position for id ".$row->id." to $new_pos");
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
