#!/usr/bin/env perl
use warnings;
use strict;
use LWP::Simple;
use XML::RSS;
use File::Spec;
use DBI;
use YAML qw(LoadFile);
use Log::Log4perl qw(get_logger);
#Perl program for parsing a podcast and download the pods
my ($yaml) = YAML::LoadFile("pepol.conf")
	or die "Could not load Config";

#configuration of the logging
my $config = q~
	log4perl.logger				= INFO, LogFile
	log4perl.appender.LogFile		= Log::Log4perl::Appender::File
	log4perl.appender.LogFile.filename	= ~.$yaml->{'logfile'}.q~
	log4perl.appender.LogFile.layout	= Log::Log4perl::Layout::PatternLayout
	log4perl.appender.LogFile.layout.ConversionPattern = [%d] [%p] - %m
~;
#initial of the logger
Log::Log4perl->init( \$config );
my $logger = get_logger();

$logger->info("Start pepol\n");

my $file = "";
$SIG{INT} = \&catch;

#Initial DB
my $dbh = &connect_db; 

foreach (@{$yaml->{'urls'}}) {
	chomp;
	next if(/^\#+/);
	my ($url, $lang) = split /;/, $_;
	my $content = get $url;
	unless (defined($content)){
		$logger->error("Could not connect to $url\n"); 
		next;}
	my $rss = XML::RSS->new;
	$rss->parse($content);
	my $count = 0;
	my $title = $rss->{channel}->{title};
	foreach my $item (@{$rss->{'items'}}) {
		my $podcast = $item->{'enclosure'}->{'url'};
		if($podcast =~ /\w+\.\w+$/) {
			if (defined($lang) and $lang gt "") {
				$file = File::Spec->catfile($yaml->{'dir'}, $lang);
				mkdir($file) unless (-e $file);
				$file = File::Spec->catfile($file, $title);
			} else {
				$file = File::Spec->catfile($yaml->{'dir'}, $title);
			}
			mkdir($file) unless (-e $file);
			$file = File::Spec->catfile($file, $&);
			#print $file."\n";
			if (&in_db($dbh,$&)) {
				$logger->debug("File exist: $file\n");
			} else {
				$logger->info("Start Download: $file\n");
				getstore($podcast, $file)
					or $logger->error("Failed Download: $file\n");
				$logger->info("Finished Download: $file\n");
				&add_podcast($dbh, $&, $title, $lang || "-", $file);
				$file = "";
				$count++;
			}
		}
	}
	$logger->info($rss->{channel}->{title}.": ".$count." File(s) downloaded.\n");
}
$logger->info("Stop pepol\n");
$dbh->disconnect;

sub connect_db {
	my $dbh = DBI->connect("DBI:CSV:f_dir=./csvdb")
		or die "Cannot connect: $DBI::errstr";
	unless (-e File::Spec->catfile("csvdb",$yaml->{'podcastdb'})) {
		my $sth = $dbh->prepare("CREATE TABLE $yaml->{'podcastdb'} (title VARCHAR(30), channel VARCHAR(30), folder VARCHAR(30), path VARCHAR(60), date VARCHAR(40))");
		$sth->execute or die "Cannot execute: " . $sth->errstr ();
		$sth->finish;
	}
	return $dbh;
}

sub add_podcast {
	my ($dbh, $title, $channel, $folder, $path) = @_;
	my $time = localtime;
	$dbh->do("INSERT INTO $yaml->{'podcastdb'} VALUES (?,?,?,?,?)", undef, $title, $channel, $folder, $path, $time);
}

sub in_db{
	my ($dbh, $title) = @_;
	my $sth = $dbh->prepare("SELECT title FROM $yaml->{podcastdb} WHERE title=?");
	$sth->execute($title);
	while (my @row = $sth->fetchrow_array) {
		if ($row[0] eq $title) {
			return 1;
		}
	}
	return 0;
}

sub catch {
	$SIG{INT} = \&catch;
	my $warn = "Interrupt pepol\n";
	unlink($file);
	$logger->warn($warn);
	print $warn;
	exit;
}
