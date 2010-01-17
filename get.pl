#!/usr/bin/env perl
use warnings;
use strict;
use LWP::Simple;
use XML::RSS;
#Perl program for parsing a podcast and download the pods

#my $url = "http://podcast.wdr.de/quarks.xml";
#my $url = "http://www.pofacs.de/rss/itunes.xml";
my $folder = "/home/christian/"; #folder where the podcast lay, musst end with /
my @urls = qw( 
http://www.pofacs.de/rss/itunes.xml
);

foreach my $url (@urls) {
	my $content = get $url
		or die;
	my $rss = XML::RSS->new;
	$rss->parse($content);
	my $title = $rss->{channel}->{title};
	foreach my $item (@{$rss->{'items'}}) {
		my $podcast = $item->{'enclosure'}->{'url'};
		if($podcast =~ /\w+\.\w+$/) {
			my $file = $folder.$title."/".$&;
			print $file."\n";
			if (-e $file) {
				print "File exist\n";
			} else {
				getstore($podcast, $file);
				#print "Need download\n";
			}
		}
	}
}

