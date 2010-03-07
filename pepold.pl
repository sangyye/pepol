#!/usr/bin/env perl
use warnings;
use strict;
use LWP::Simple;
use XML::RSS;
use File::Spec;
use YAML qw(LoadFile);
use Log::Log4perl qw(get_logger);
use Pepol;
#Perl program for parsing a podcast and download the pods
my ($yaml) = YAML::LoadFile("pepol.conf")
    or die "Could not load Config";

#configuration of the logging
my $config = q~
    log4perl.logger             = INFO, LogFile
    log4perl.appender.LogFile       = Log::Log4perl::Appender::File
    log4perl.appender.LogFile.filename  = ~.$yaml->{'logfile'}.q~
    log4perl.appender.LogFile.layout    = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.LogFile.layout.ConversionPattern = [%d] [%p] - %m
~;
#initial of the logger
Log::Log4perl->init( \$config );
my $logger = get_logger();

$logger->info("Start pepol\n");

my $file = "";
$SIG{INT} = \&catch;

#Initial Pepol
my $pepol = Pepol->new(
        podcastdb => $yaml->{podcastdb},
);

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
    foreach my $item (reverse @{$rss->{'items'}}) {
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
            if ($pepol->in_db($&)) {
                $logger->debug("File exist: $file\n");
            } elsif ( -e $file) {
                my @fstat = stat $file;
                $pepol->add_podcast($&, $title, $lang || "-", $file, $fstat[9]);
                $logger->debug("File add to db: $file\n");
            } else {
                $logger->info("Start Download: $file\n");
                getstore($podcast, $file)
                    or $logger->error("Failed Download: $file\n");
                $logger->info("Finished Download: $file\n");
                $pepol->add_podcast($&, $title, $lang || "-", $file);
                $file = "";
                $count++;
            }
        }
    }
    $logger->info($rss->{channel}->{title}.": ".$count." File(s) downloaded.\n");
}
$logger->info("Stop pepol\n");

sub catch {
    $SIG{INT} = \&catch;
    my $warn = "Interrupt pepol\n";
    unlink($file);
    $logger->warn($warn);
    print $warn;
    exit;
}
