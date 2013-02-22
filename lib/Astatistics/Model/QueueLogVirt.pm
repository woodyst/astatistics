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

package Astatistics::Model::QueueLogVirt;
use Moose;
use namespace::autoclean;
use DateTime;
use DateTime::Format::MySQL;
use YAML;
use Catalyst::Model;
use Astatistics::Model::Asterisk;

extends 'Catalyst::Model';

has 'resultset' => (
	is => 'rw', isa => 'DBIx::Class::ResultSet'
);

has 'series' => (
	is => 'rw', isa => 'ArrayRef'
);

has 'values' => (
	is => 'rw', isa => 'HashRef'
);

has 'keys' => (
	is => 'rw', isa => 'ArrayRef'
);

has 'result' => (
	is => 'rw', isa => 'HashRef'
);

has 'columns' => (
	is => 'rw', isa => 'ArrayRef'
);

has 'msg' => (
	is => 'rw', isa => 'Str', default => ""
);

has 'show' => (
	is => 'ro', isa => 'Str', default => ""
);

has 'where' => (
	is => 'ro', isa => 'Str', default => ""
);

has 'order_by' => (
	is => 'ro', isa => 'Str'
);

has 'group_by' => (
	is => 'ro', isa => 'Str'
);

has 'series_by' => (
	is => 'ro', isa => 'Str', default => ''
);

has 'date_from' => (
	is => 'ro', isa => 'Str', default => '0000-01-01 00:00:00'
);

has 'date_to' => (
	is => 'ro', isa => 'Str', default => '2037-12-31 23:59:59'
);

has 'datetime_from' => (
	is => 'ro', isa => 'DateTime', lazy_build => 1
);

has 'datetime_to' => (
	is => 'ro', isa => 'DateTime', lazy_build => 1
);

has 'epoch_from' => (
	is => 'ro', isa => 'Str', lazy_build => 1
);

has 'epoch_to' => (
	is => 'ro', isa => 'Str', lazy_build => 1
);

has 'agents' => (
	is => 'rw', isa => 'HashRef'
);

has 'calls' => (
	is => 'rw', isa => 'HashRef'
);

has 'queues' => (
	is => 'rw', isa => 'HashRef'
);

has 'app' => (
	is => 'rw', isa => 'Object'
);

sub msg_html {
	my $self = shift;

	my $msg = $self->msg;
	$msg =~ s/\n/<hr\/>/g;
	$msg .= "<hr/>";
	return $msg;
}

sub addmsg {
	my $self = shift;
	my $addition = shift;

	if (defined $addition and $addition) {
		$self->msg($self->msg . "\n" . $addition);
	}
	return $self->msg;
}

sub _parse_date {
	my $self = shift;
	my $datetime = shift;
	my $mode = shift;

	if ($datetime =~ /^\s*[0-9]+-[0-9]+-[0-9]+\s*$/) {
		my $time = "00:00:00";
		if ($mode eq "to") {
			$time = "23:59:59";
		}
		$datetime .= " ".$time;
	}
	return $datetime;
}

sub _build_datetime_from {
	my $self = shift;

	my $datetime = $self->_parse_date($self->date_from,"from");
	return DateTime::Format::MySQL->parse_datetime($datetime);
}

sub _build_datetime_to {
	my $self = shift;

	my $datetime = $self->_parse_date($self->date_to,"to");
	return DateTime::Format::MySQL->parse_datetime($datetime);
}

sub _build_epoch_from {
	my $self = shift;

	return $self->datetime_from->epoch;
}

sub _build_epoch_to {
	my $self = shift;

	return $self->datetime_to->epoch;
}

sub BUILD {
	my $self = shift;

	#$self->addmsg($app);

	$self->addmsg("Date from ".$self->date_from." (".$self->epoch_from."), to ".$self->date_to." (". $self->epoch_to . ")");

	$self->addmsg("Checking needs...");

	# Parse show:
	#	- fields: wait_time, spk_time, avg_call_duration, max_call_duration, min_call_duration, calls, calls_num, calls_wait_time (total, avg, max, min), calls_answered, calls_dropped ...

	# query_log events:
	# - Position in queue: ABANDON
	# - AGENT: AGENTDUMP, AGENTLOGIN, AGENTLOGOFF, AGENTCALLBACKLOGOFF, COMPLETEAGENT, CONNECT, RINGNOANSWER, SYSCOMPAT, TRANSFER
	# - CALLER: COMPLETEAGENT, COMPLETECALLER, CONNECT, ENTERQUEUE, EXITEMPTY, EXITWITHKEY, EXITWITHTIMEOUT, RINGNOANSWER, SYSCOMPAT, TRANSFER
	# - Call Agent: AGENTLOGIN, AGENTLOGOFF, AGENTCALLBACKLOGOFF, COMPLETECALLER, COMPLETEAGENT, CONNECT, TRANSFER
	# - Call Caller: COMPLETEAGENT, COMPLETECALLER, CONNECT, RINGNOANSWER, SYSCOMPAT, TRANSFER
	
	my %events_needed_for = (
														logged_time => [ 'AGENTLOGIN', 'COMPLETEAGENT', 'COMPLETECALLER', 'CONNECT', 'TRANSFER', 'AGENTLOGOFF', 'AGENTCALLBACKLOGOFF' ],
														wait_time		=> [ 'AGENTLOGIN', 'COMPLETEAGENT', 'COMPLETECALLER', 'CONNECT', 'TRANSFER', 'AGENTLOGOFF', 'AGENTCALLBACKLOGOFF' ],
														spk_time		=> [ 'COMPLETEAGENT', 'COMPLETECALLER', 'CONNECT', 'AGENTLOGOFF' ],
														call_duration => [ 'CONNECT', 'COMPLETECALLER', 'COMPLETEAGENT', 'SYSCOMPAT', 'TRANSFER' ],
														calls				=> [ 'AGENTLOGIN', 'AGENTLOGOFF', 'AGENTCALLBACKLOGOFF', 'COMPLETECALLER', 'COMPLETEAGENT', 'CONNECT', 'TRANSFER' ],
														callers_wait_time => [ 'ENTERQUEUE', 'CONNECT', 'EXITEMPTY', 'EXITWITHKEY', 'EXITWITHTIMEOUT', 'RINGNOANSWER', 'SYSCOMPAT', 'TRANSFER' ],
														calls_answered => [ 'CONNECT', 'SYSCOMPAT' ],
														calls_dropped => [ 'CONNECT', 'EXITEMPTY', 'ENTERQUEUE', 'EXITWITHKEY', 'EXITWITHTIMEOUT', 'RINGNOANSWER', 'SYSCOMPAT' ],
	);

	my %events_needed;
	my @show = split(/\s*(?<!\\),\s*/, $self->show);

	my @keys;
	for my $show (@show) {
		$self->addmsg("Show $show found");
		$show =~ s/.*\(//g;
		$show =~ s/\).*//g;
		$show =~ s/^(min|max|avg|sum)_//;
		if ($show) {
			if (exists $events_needed_for{$show}) {
				push (@keys, $show) if (not $show ~~ @keys);
				for my $event (@{$events_needed_for{$show}}) {
					$events_needed{$event} = 1;
				}
			}
		}
		if (exists $events_needed_for{$show}) {
			$self->addmsg("QueryProcess: Events needed for $show: ".join(", ",@{$events_needed_for{$show}}));
		}
	}
	$self->addmsg("QueryProcess: Events needed: ".join(", ",keys %events_needed));

	my %event_query;
	my %params;

	my %events = ( -or => [] );

	for my $event (keys %events_needed) {
		push @{$events{'-or'}}, { event => $event };
	}

	my $where = $self->where;
	$where =~ s/XXXDATESQLOGVIRTXXX.*XXXDATESQLOGVIRTXXX//;	# This was for asking for parameters, but is passed as individual conditions so hasn't to be in where.
	$event_query{'-and'} = [ $where, \%events ];

	my %date_from_query = ( 'time+0' => { '>', $self->epoch_from } );	# `field`+0 for numeric
	my %date_to_query = ( 'time+0' => { '<', $self->epoch_to } );			# 					threatement

	# FIXME: (see explanation)
	my %query = ( -and => [ \%events, \%date_from_query, \%date_to_query ]);
	# Next includes where condition from template, but requires parsing and converting to hash format of DBIx::Class.
	#my %query = ( -and => [ \%event_query, \%date_from_query, \%date_to_query ]);

	my %query_params;
	$query_params{'order_by'} = 'time+0,id,callid+0';	# `field`+0 for numeric sort

	my $schema = Astatistics::Model::Asterisk->new;
	my $rs = $schema->resultset('QueueLog')->search({ -and => [ \%query ] }, \%query_params );
	my @columns = $rs->result_source->columns;
	$self->columns(\@columns);
	$self->resultset($rs);

	# Result publication: Result is an arrayref of series of vfields for this query.
	#	- fields: wait_time, spk_time, avg_call_duration, max_call_duration, min_call_duration, calls, calls_num, calls_wait_time (total, avg, max, min), calls_answered, calls_dropped ...

	# query_log events:
	# - Position in queue: ABANDON
	# - AGENT: AGENTDUMP, AGENTLOGIN, AGENTLOGOFF, AGENTCALLBACKLOGOFF, COMPLETEAGENT, CONNECT, RINGNOANSWER, SYSCOMPAT, TRANSFER
	# - CALLER: COMPLETEAGENT, COMPLETECALLER, CONNECT, ENTERQUEUE, EXITEMPTY, EXITWITHKEY, EXITWITHTIMEOUT, RINGNOANSWER, SYSCOMPAT, TRANSFER
	# - Call Agent: AGENTLOGIN, AGENTLOGOFF, AGENTCALLBACKLOGOFF, COMPLETECALLER, COMPLETEAGENT, CONNECT, TRASFER
	# - Call Caller: COMPLETEAGENT, COMPLETECALLER, CONNECT, RINGNOANSWER, SYSCOMPAT, TRANSFER
	# vfields: wait_time spk_time call_duration calls callers_wait_time calls_answered calls_dropped
	
	# events_vfield: 1 starts time, 0 stops
	my %events_vfield = (
												logged_time => { 	
																				AGENTDUMP => 1,
																				AGENTLOGIN => 1,
																				AGENTLOGOFF => 0,
																				AGENTCALLBACKLOGOFF => 0,
																				COMPLETEAGENT => 1,
																				COMPLETECALLER => 1,
																				CONNECT => 1,
																				# RINGNOANSWER => ,
																				SYSCOMPAT => 1,
																				TRANSFER => 1,
																				# ENTERQUEUE => ,
																				# EXITEMPTY => ,
																				# EXITWITHKEY => ,
																				# EXITWITHTIMEOUT => ,
																				# RINGNOANSWER => ,
																				# ABANDON => ,
																			},
												wait_time => { 	
																				# AGENTDUMP => ,
																				AGENTLOGIN => 1,
																				AGENTLOGOFF => 0,	# before COMPLETEAGENT/CALLER
																				AGENTCALLBACKLOGOFF => 0,
																				COMPLETEAGENT => 1,
																				COMPLETECALLER => 1,
																				CONNECT => 0,
																				# RINGNOANSWER => ,
																				SYSCOMPAT => 1,
																				TRANSFER => 1,
																				ENTERQUEUE => 1,
																				EXITEMPTY => 0,
																				EXITWITHKEY => 0,
																				EXITWITHTIMEOUT => 0,
																				RINGNOANSWER => 0,
																				ABANDON => 0,
																			},
												spk_time => { 	
																				# AGENTDUMP => ,
																				AGENTLOGIN => 0,
																				AGENTLOGOFF => 0,
																				AGENTCALLBACKLOGOFF => 0,
																				COMPLETEAGENT => 0,
																				COMPLETECALLER => 0,
																				CONNECT => 1,
																				# RINGNOANSWER => ,
																				SYSCOMPAT => 0,
																				TRANSFER => 0,
																				# ENTERQUEUE => ,
																				# EXITEMPTY => ,
																				# EXITWITHKEY => ,
																				# EXITWITHTIMEOUT => ,
																				# RINGNOANSWER => ,
																				# ABANDON => ,
																			},
												call_duration => {
																				# AGENTDUMP => ,
																				# AGENTLOGIN => 0,
																				# AGENTLOGOFF => 0,
																				# AGENTCALLBACKLOGOFF => 0,
																				COMPLETEAGENT => 0,
																				COMPLETECALLER => 0,
																				CONNECT => 1,
																				# RINGNOANSWER => ,
																				SYSCOMPAT => 0,
																				TRANSFER => 0,
																				# ENTERQUEUE => ,
																				EXITEMPTY => 0,
																				EXITWITHKEY => 0,
																				EXITWITHTIMEOUT => 0,
																				RINGNOANSWER => 0,
																				# ABANDON => ,
																			},
												calls_wait_time => {
																				# AGENTDUMP => ,
																				# AGENTLOGIN => 0,
																				# AGENTLOGOFF => 0,
																				# AGENTCALLBACKLOGOFF => 0,
																				COMPLETEAGENT => 0,
																				COMPLETECALLER => 0,
																				CONNECT => 0,
																				# RINGNOANSWER => ,
																				SYSCOMPAT => 0,
																				TRANSFER => 0,
																				ENTERQUEUE => 1,
																				EXITEMPTY => 0,
																				EXITWITHKEY => 0,
																				EXITWITHTIMEOUT => 0,
																				RINGNOANSWER => 0,
																				# ABANDON => ,
																			},
												calls_answered => {
																				# AGENTDUMP => ,
																				# AGENTLOGIN => 0,
																				# AGENTLOGOFF => 0,
																				# AGENTCALLBACKLOGOFF => 0,
																				# COMPLETEAGENT => 0,
																				# COMPLETECALLER => 0,
																				CONNECT => 1,
																				# RINGNOANSWER => ,
																				# SYSCOMPAT => 0,
																				# TRANSFER => 0,
																				# ENTERQUEUE => 0,
																				# EXITEMPTY => 0,
																				# EXITWITHKEY => 0,
																				# EXITWITHTIMEOUT => 0,
																				# RINGNOANSWER => 0,
																				# ABANDON => ,
																			},
												calls => {
																				# AGENTDUMP => ,
																				# AGENTLOGIN => 0,
																				# AGENTLOGOFF => 0,
																				# AGENTCALLBACKLOGOFF => 0,
																				# COMPLETEAGENT => 0,
																				# COMPLETECALLER => 0,
																				# CONNECT => 0,
																				# RINGNOANSWER => ,
																				# SYSCOMPAT => 0,
																				# TRANSFER => 0,
																				ENTERQUEUE => 1,
																				# EXITEMPTY => 0,
																				# EXITWITHKEY => 0,
																				# EXITWITHTIMEOUT => 0,
																				# RINGNOANSWER => 0,
																				# ABANDON => ,
																			},
	);
	#	- fields: total, avg, max, min of wait_time, spk_time, call_duration, calls_wait_time, calls, calls_num, calls_answered, calls_dropped ...

	my %result;
	my %callids_num;	# callid => num
	if ($self->series_by) {
		my @series_by = split(/\s*(?<!\\),\s*/, $self->series_by);
		my $serie_num = 0;
		for my $serie (@series_by) {
			# TODO:
			#
			# Ojo series calls (no campo, revisar si infoN o similar para ciertos eventos
			# (caso especial).

			$self->addmsg("Detected new serie by $serie");
			$result{$serie} = {};
			my $schema = Astatistics::Model::Asterisk->new;
			$query_params{group_by} = $serie;
			if ($serie eq "call") {
				$query_params{columns} = [ "callid", "data", "event" ];
				$query_params{group_by} = "callid";
			} else {
				$query_params{columns} = $serie;
			}
			my $series_rs = $schema->resultset('QueueLog')->search({ -and => [ \%query ] }, \%query_params );
			while (my $row = $series_rs->next) {
				my $value = "";
				if ($serie eq "call") {
					my $row_event = $row->event;
					$value = $row->callid;
					if (defined $row_event and $row_event eq "ENTERQUEUE") {
						my $dataval = $row->{"data"};
						my @dataval = split(/(?<!\\)\|/, $value);
						if (exists $dataval[1]) {
							$callids_num{$value} = $dataval[1];
						}
					}
				} else {
					$value = $row->$serie;
				}
				
				if ($value and $value ne "NONE") {
					$self->addmsg("Detected new key for serie $serie: $value");
					$result{$serie}->{$value} = "";
				}
			}
		}
		$serie_num++;
	}
	$result{total} = { "total" => {} };

	# Generate result
	my @series;
	my %values;
	for my $serie (sort keys %result) {
		# TODO:
		#
		# Ojo series calls (no campo, revisar si infoN o similar para ciertos eventos
		# (caso especial).
		#
		# Result ha de ser un hash de series como claves, y como valor un hash
		# de valor de serie y otro hash como valor de resultados solicitados
		# (key = vcampo, valor = valor).

		# Por tanto, para cada serie generar key de valor de serie, calcular
		# valores para vcampos solicitados y rellenar (la misma búsqueda servirá).

		# Para ello generar estructuras inicialmente y luego ir sumando/restando/
		# normalizando valores en vivo (hacer hash de EVENTO -> { vcampo => operación })
		# (hecho arriba) y procesar evento a evento, aplicando según valor de clave
		# (agente, llamada, ...).

		# Ir calculando con campos de almacenamiento temporal:
		# tmp->agente->agente1->spk_time = start->(time)
		# Al encontrar cambio estado spk_time{agente1}:
		# result->agente->agente1->spk_time += (time) y resetear tmp.
		# Un stop sin un start supone tiempo anterior utilizado (revisar), por lo que
		# calcular desde hora comienzo. Probablemente se tendran que definir eventos
		# que sí cuentan y otros que no.
		# Al final repasar valores sin terminar y completar con hora fin.

		next if ($serie eq "total");	# total always applies in other series
		push @series, $serie;
		$values{$serie} = [];

		$self->addmsg("Processing serie $serie");

		my %last_start;	# last_start{value}->{event} = epoch
		my %status; # 1 => started, 0 => stopped
		my %found; # 1 => found almost one event, 0 => not found any event
		for my $value (keys %{$result{$serie}}) {
			push @{$values{$serie}}, $value;
			$last_start{$value} = {};
			$status{$value} = {};
			$found{$value} = {};
			$self->addmsg("Processing value $value in serie $serie");
			$query_params{group_by} = "";
			delete $query_params{columns};
			my $series_rs;
			if ($serie ne "total") {
				my $query_serie_field = $serie;
				my $query_value;
				if ($query_serie_field eq "call") {
					$query_serie_field = "callid";
				}
				$query_value = $value;
				$series_rs = $schema->resultset('QueueLog')->search({ -and => [ \%query, { $query_serie_field => $query_value } ] }, \%query_params );
			} else {
				$series_rs = $schema->resultset('QueueLog')->search(\%query, \%query_params );
			}
			$result{$serie}->{$value} = {};
			#for my $show (@show) {
			#	$self->addmsg("\$result{$serie}->{$value} = " . $result{$serie}->{$value});
			#	$result{$serie}->{$value}->{$show} = "0"; 
			#}
			while (my $row = $series_rs->next) {
				my $event = $row->event;
				if (defined $event and $event and $event ne "NONE") {
					$self->addmsg("Event $event");
					for my $show (@show) {
						$show =~ s/.*\(//g;
						$show =~ s/\).*//g;
						$show =~ s/^(min|max|avg|sum)_//;
						if (!exists($last_start{$value}->{$show})) {
							$last_start{$value}->{$show} = 0;
							$status{$value}->{$show} = 0;
						}
						if (!exists $result{$serie}->{$value}->{$show}) {
							$result{$serie}->{$value}->{$show} = "0"; 
						}
						if (!exists $result{total}->{total}->{$show}) {
							$result{total}->{total}->{$show} = "0"; 
						}
						if (!exists($found{$value}->{$show})) {
							$found{$value}->{$show} = 0;
						}
						my $func = $1;
						$func = "sum" if (!defined $func or !$func);
						if ($show) {
							if (!exists $events_vfield{$show} or !exists $events_vfield{$show}->{$event}) {
								$self->addmsg("Events description for $show not found");
							} else {
								$self->addmsg("Events description for $show found");
								my $exists = 0;
								$exists = 1 if (exists $events_vfield{$show} and exists $events_vfield{$show}->{$event});
								my $action = $events_vfield{$show}->{$event} if $exists;
								my $epoch = $row->time;
								if (defined $epoch and $epoch and $epoch ne "NONE") {
									if ($show =~ /_time$/ or $show =~ /_duration$/ and $epoch) {
										my $epoch_start;
										my $epoch_end;
										my $process_time = 0;
										if ($exists) {
											if ($action and !$status{$value}->{$show}) {	# start
												$found{$value}->{$show} = 1;
												$self->addmsg("Action start found for event $show, event: $event: $action, last_start{$value}->{$show} pasará a ser $epoch");
												# last_start{$value}->{$show} (value es el agente o llamada)
												if ($last_start{$value}->{$show}) {
													$self->addmsg("Encontrado last_start{$value}->{$show}, por lo que se procesa con dicha fecha");
													$epoch_start = $last_start{$value}->{$show};
													$epoch_end = $epoch;
													$process_time = 1;
												}
												$last_start{$value}->{$show} = $epoch;
												$status{$value}->{$show} = 1;
											} elsif (!$action and $status{$value}->{$show}) {	# stop
												$self->addmsg("Action stop found for event $show, event: $event, epoch_end: $epoch");
												if ($last_start{$value}->{$show}) {
													$self->addmsg("last_start for $value found: $last_start{$value}->{$show}");
													$epoch_start = $last_start{$value}->{$show};
												} elsif (!$found{$value}->{$show}) {
													$self->addmsg("last_start for $value not found, so start value to epoch_from: ".$self->epoch_from);
													$epoch_start = $self->epoch_from;
												} else {
													$self->addmsg("last_start for $value not found, but it was found before, so doing nothing");
												}
												$epoch_end = $epoch;
												$process_time = 1;
												$last_start{$value}->{$show} = 0;	# Continue
												#$last_start{$value}->{$show} = 0 if ($status{$value}->{$show});
												$status{$value}->{$show} = 0;
												$found{$value}->{$show} = 1;
											} elsif (!$action and !$status{$value}->{$show}) { # stop when stopped
												$self->addmsg("Stop when stopped. Reset last_start.");
												$status{$value}->{$show} = 0;
												$last_start{$value}->{$show} = 0;
											} elsif ($action and $status{$value}->{$show}) { # start when started
												$self->addmsg("Start when started. Doing nothing.");
											}
										}
										if ($process_time) {
											if ($func eq "max") {
												my $interval = $epoch_end - $epoch_start;
												$result{$serie}->{$value}->{$show} = $interval if ($interval > $result{$serie}->{$value}->{$show});
												$self->addmsg("result->$serie->$value->$show, func $func, updated to ".$result{$serie}->{$value}->{$show});
												$result{total}->{total}->{$show} = $interval if ($interval > $result{total}->{total}->{$show});
												$self->addmsg("result->total->total->$show, func $func, updated to ".$result{total}->{total}->{$show});
											} elsif ($func eq "min") {
												my $interval = $epoch_end - $epoch_start;
												$result{$serie}->{$value}->{$show} = $interval if ($interval < $result{$serie}->{$value}->{$show});
												$self->addmsg("result->$serie->$value->$show, func $func, updated to ".$result{$serie}->{$value}->{$show});
												$result{total}->{total}->{$show} = $interval if ($interval < $result{total}->{total}->{$show});
												$self->addmsg("result->total->total->$show, func $func, updated to ".$result{total}->{total}->{$show});
											} elsif ($func eq "avg") {
												my $interval = $epoch_end - $epoch_start;
												$result{$serie}->{$value}->{$show} = $interval * $result{$serie}->{$value}->{$show} / 2;
												$self->addmsg("result->$serie->$value->$show, func $func, updated to ".$result{$serie}->{$value}->{$show});
												$result{total}->{total}->{$show} = $interval * $result{total}->{total}->{$show} / 2;
												$self->addmsg("result->total->total->$show, func $func, updated to ".$result{total}->{total}->{$show});
											} elsif ($func eq "sum" or !$func) {
												my $interval = $epoch_end - $epoch_start;
												my $result = $result{$serie}->{$value}->{$show};
												$result += $interval;
												$result{$serie}->{$value}->{$show} = $result;
												$self->addmsg("result->$serie->$value->$show, func $func, updated to ".$result{$serie}->{$value}->{$show}.", epoch_start: $epoch_start, epoch_end: $epoch_end");
												my $result_total = $result{total}->{total}->{$show};
												$result_total += $interval;
												$result{total}->{total}->{$show} = $result_total;
												$self->addmsg("result->total->total->$show, func $func, updated to ".$result{total}->{total}->{$show}.", epoch_start: $epoch_start, epoch_end: $epoch_end");
											}
										}
									} else {
										$result{$serie}->{$value}->{$show}++;
										$self->addmsg("result->$serie->$value->$show updated to ".$result{$serie}->{$value}->{$show});
										$result{total}->{total}->{$show}++;
										$self->addmsg("result->total->total->$show updated to ".$result{total}->{total}->{$show});
									}
								}
							}
						}
						if (exists $events_needed_for{$show}) {
							#$self->addmsg("QueryProcess: Events needed for $show: ".join(", ",@{$events_needed_for{$show}}));
						}
					}
					#$self->addmsg("QueryProcess: Events needed: ".join(", ",keys %events_needed));
				}
			}
			# TODO: añadir restos no acabados
		}
	}

	for my $serie (sort keys %result) {
		$self->addmsg("Serie: $serie");
		for my $value (sort keys %{$result{$serie}}) {
			$self->addmsg("Value: $value");
			for my $show (sort keys %{$result{$serie}->{$value}}) {
				$self->addmsg("$show -> $result{$serie}->{$value}->{$show}");
			}
		}
	}

	push @series, "total";
	$values{"total"} = [ "total" ];

	# Validar result con where y aplicar a total.
	# Para ello parsear where y luego aplicar a cada registro de result. Después se ha de ajustar total.
	
	# for my $serie (keys %result) {
	#		# ojo, valores pueden no estar en show y sí estar en where?
	# 	for my $value (keys $result{$serie}) {
	#			if (!test_where($serie, $value, $where)) {
	#				delete $result{$serie}->{$value};
	#				for (my $num = 0; $num <= $#values; $num++) {
	#					delete $values{$serie}->[$num] if $values{$serie}->[$num] == $value;
	#				}
	#				# adjust total
	#			}
	#		}
	#	}

	$self->series(\@series);
	$self->values(\%values);
	$self->keys(\@keys);
	$self->result(\%result);

	return $self;
}


=head1 NAME

Astatistics::Model::QueueLogVirt - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
