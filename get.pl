#!/usr/bin/env perl
use warnings;
use strict;
use LWP::Simple;
use XML::RSS;
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

#my $url = "http://podcast.wdr.de/quarks.xml";
#my $url = "http://www.pofacs.de/rss/itunes.xml";
my $folder = "/home/christian/"; #folder where the podcast lay, musst end with /
my @urls = qw( 
http://www.pofacs.de/rss/itunes.xml
);

foreach my $url (@urls) {
	my $content = get $url
		or $logger->warn("Could not connect to $url\n");
	my $rss = XML::RSS->new;
	$rss->parse($content);
	my $title = $rss->{channel}->{title};
	foreach my $item (@{$rss->{'items'}}) {
		my $podcast = $item->{'enclosure'}->{'url'};
		if($podcast =~ /\w+\.\w+$/) {
			my $file = $folder.$title."/".$&;
			print $file."\n";
			if (-e $file) {
				$logger->info("File exist: $&\n");
			} else {
				getstore($podcast, $file);
				#print "Need download\n";
			}
		}
	}
}

