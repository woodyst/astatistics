#!/usr/bin/env perl

use strict;
no strict 'refs';
use warnings;
use DBI;
use Text::CSV;

my $db = "asterisk";
my $host = "localhost";
my $port = "3306";
my $user = "root";
my $pass = "4321";

my $source_cdr_dir = "/var/log/asterisk/cdr-csv";
my $source_queue_log_dir = "/var/log/asterisk";
my $cdr_basename = "Master.csv";
my $queue_log_basename = "queue_log";
my $tmpdir = "/tmp/asterisk_log_importer";
my $tmpfile = $tmpdir . "/master.csv";

my $dsn = "DBI:mysql:database=$db;host=$host;port=$port";
my $dbh = DBI->connect($dsn, $user, $pass);

system("mkdir -p $tmpdir") if (! -f $tmpdir);

my @opt = @ARGV;

# CDR-CSV
if (not "-nc" ~~ @opt) {
	my %files;

	opendir(DIR, $source_cdr_dir);
	while (my $file = readdir(DIR)) {
		next if $file !~ /^$cdr_basename\.?([0-9]*)?(\.gz)?$/;
		my $index = $1;
		$index = 0 if (!defined $index or !$index);
		$files{$index} = $file;
	}

	if (-f $tmpfile) {
		system("rm $tmpfile");
	}

	for my $key (sort { $b <=> $a } keys %files) {
		print "Processing $key $files{$key}\n";
		my $file = $files{$key};
		my $cmd = "cat";
		if ($file =~ /\.gz/) {
			$cmd = "zcat";
		}
		system("$cmd $source_cdr_dir/$file >> $tmpfile");
	}

	my $csv = Text::CSV->new();

	my @fields = ('calldate', 'clid', 'src', 'dst', 'dcontext', 'channel', 'dstchannel', 'lastapp', 'lastdata', 'duration', 'billsec', 'disposition', 'amaflags', 'accountcode', 'userfield', 'uniqueid', 'linkedid', 'sequence', 'peeraccount');

	open (CSV, "<", $tmpfile) or die $!;
	while (<CSV>) {
		if ($csv->parse($_)) {
			my @column = $csv->fields();
			#print "@column\n";
			if (@column) {
				my $num = 1;
				#for my $val (@column) {
				#	print "$num -> $val |";
				#	$num++;
				#}
				#print "\n";
				my ($accountcode,$src,$dst,$dcontext,$clid,$channel,$dstchannel,$lastapp,$lastdata,$start,$answer,$end,$duration,$billsec,$disposition,$amaflags,$uniqueid,$userfield) = @column;

				for my $field (@fields) {
					if (!defined $$field or !$$field) {
						$$field = '';
					}
				}

				my $values = $dbh->quote($start).",".$dbh->quote($clid).",".$dbh->quote($src).",".$dbh->quote($dst).",".$dbh->quote($dcontext).",".$dbh->quote($channel).",".$dbh->quote($dstchannel).",".$dbh->quote($lastapp).",".$dbh->quote($lastdata).",".$dbh->quote($duration).",".$dbh->quote($billsec).",".$dbh->quote($disposition).",".$dbh->quote($amaflags).",".$dbh->quote($accountcode).",".$dbh->quote($userfield).",".$dbh->quote($uniqueid).",".$dbh->quote('').",".$dbh->quote('').",".$dbh->quote('');
				$dbh->do("insert into cdr (".join(",",@fields).") values (".$values.")");
			}
		}
	}
	close CSV;
	closedir DIR;
}


# QUEUE_LOG
if (not "-nq" ~~ @opt) {
	my %queue_files;
	QUEUE: opendir(QUEUELOG_DIR, $source_queue_log_dir);
	while (my $file = readdir(QUEUELOG_DIR)) {
		next if $file !~ /^$queue_log_basename\.?([0-9]*)?(\.gz)?$/;
		my $index = $1;
		$index = 0 if (!defined $index or !$index);
		$queue_files{$index} = $file;
	}

	if (-f $tmpfile) {
		system("rm $tmpfile");
	}

	for my $key (sort { $b <=> $a } keys %queue_files) {
		print "Processing $key $queue_files{$key}\n";
		my $file = $queue_files{$key};
		my $cmd = "cat";
		if ($file =~ /\.gz/) {
			$cmd = "zcat";
		}
		system("$cmd $source_queue_log_dir/$file >> $tmpfile");
	}

	my $csv = Text::CSV->new({ sep_char => '|' });

	my @fields = ('time','callid','queuename','agent','event','info1','info2','info3');
	my @dbfields = ('time','callid','queuename','agent','event','data');

	open (QUEUE_LOG, "<", $tmpfile) or die $!;
	while (<QUEUE_LOG>) {
		if ($csv->parse($_)) {
			my @column = $csv->fields();
			my @filled_column;
			#print "@column\n";
			if (@column) {
				#my $num = 1;
				#for my $val (@column) {
				#	#print "$num -> $val |";
				#	$num++;
				#}
				#print "\n";
				my ($callid,$time,$queuename,$agent,$action,$info1,$info2,$info3) = @column;

				push (@column, 'NONE') while ($#column < 7);

				$info1 = "" if (! defined $info1);
				$info2 = "" if (! defined $info2);
				$info3 = "" if (! defined $info3);
				my $data = "$info1|$info2|$info3";
				my $values = $dbh->quote($callid).",".$dbh->quote($time).",".$dbh->quote($queuename).",".$dbh->quote($agent).",".$dbh->quote($action).",".$dbh->quote("$data");
				$dbh->do("insert into queue_log (".join(",",@dbfields).") values (".$values.")");
				print("insert into queue_log (".join(",",@dbfields).") values (".$values.")\n");
			}
		}
	}
	close QUEUE_LOG;
	closedir QUEUELOG_DIR;
}

