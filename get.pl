#!/usr/bin/env perl
use warnings;
use strict;
use LWP::Simple;
use XML::RSS;
use File::Spec;
use Log::Log4perl qw(get_logger);
#Perl program for parsing a podcast and download the pods

#configuration of the logging
my $config = q~
	log4perl.logger				= INFO, LogFile
	log4perl.appender.LogFile		= Log::Log4perl::Appender::File
	log4perl.appender.LogFile.filename	= pepol.log
	log4perl.appender.LogFile.layout	= Log::Log4perl::Layout::PatternLayout
	log4perl.appender.LogFile.layout.ConversionPattern = [%d] [%p] - %m
~;
#initial of the logger
Log::Log4perl->init( \$config );
my $logger = get_logger();

my $folder = "/home/christian"; #folder where the podcast lay

$logger->info("Start pepol\n");

open URLS, "urls.conf";

while (<URLS>) {
	chomp;
	next if(/^\#+/);
	my ($url, $lang) = split /;/, $_;
	my $content = get $url;
	unless ( defined($content)){
		$logger->error("Could not connect to $url\n");
		next;
	}
	my $rss = XML::RSS->new;
	$rss->parse($content);
	my $title = $rss->{channel}->{title};
	foreach my $item (@{$rss->{'items'}}) {
		my $podcast = $item->{'enclosure'}->{'url'};
		if($podcast =~ /\w+\.\w+$/) {
			my $file =File::Spec->catfile($title, $&);
			$file = File::Spec->catfile($lang, $file) if ( defined($lang) and $lang gt "");
			$file = File::Spec->catfile($folder, $file);
			#print $file."\n";
			if (-e $file) {
				$logger->debug("File exist: $file\n");
			} else {
				$logger->info("Start Download: $file\n");
				getstore($podcast, $file)
					or $logger->error("Failed Download: $file\n");
				$logger->info("Finished Download: $file\n");
			}
		}
	}
}
$logger->info("Stop pepol\n");
