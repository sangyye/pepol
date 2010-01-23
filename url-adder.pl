#!/usr/bin/perl
use warnings;
use strict;
use Tk;
use Tk::FBox;
use YAML qw(LoadFile DumpFile);

#Grafische Oberfläche generieren

my $main = MainWindow->new(-title => "Pepol URL-Edit");
my $input_frame = $main->Frame();
$input_frame->Label("-text" => "Podcasts:")->pack(-side => 'left');
my $folder_in = $input_frame->Entry(-width => 40);
$folder_in->pack(-side => 'left');
my $input_frame2 = $main->Frame();
$input_frame2->Label("-text" => "Logfile:")->pack(-side => 'left');
my $logfile_in = $input_frame2->Entry(-width => 38);
$logfile_in->pack(-side => 'left');
$input_frame->pack(-side => 'top');
$input_frame2->pack(-side => 'top');

my $frame = $main->Frame(-width => 50, -height => 10);
my $box = $frame->Listbox(-width => 50, -height => 10);
my $scroll = $frame->Scrollbar(-command => ['yview', $box]);
$box->configure(-yscrollcommand => ['set', $scroll]);
$box->pack(-side => 'left', -fill => 'both', -expand => 1);
$scroll->pack(-side => 'right', -fill => 'y');
$frame->pack(-side => 'top');

my $bt_add = $main->Button("-text" => "Add",
                                "-height" => "1",
                                "-width"  => "4",
                                "-command" =>  \&eingabe_bearbeiten);

my $bt_remove = $main->Button("-text" => "Remove",
				"-height" => "1",
				"-width" => "4",
				"-command" => sub{$box->delete('active')});

my $bt_save = $main->Button("-text" => "Save",
				"-height" => "1",
				"-width" => "4",
				"-command" => \&save_file);

my $bt_end = $main->Button("-text" => "Exit",
                                 "-height" => "1",
                                 "-width"  => "4",
                                 "-command" => sub{ exit;});

$bt_add->pack(-side => 'left');
$bt_remove->pack(-side => 'left');
$bt_end->pack(-side => 'right');
$bt_save->pack(-side =>  'right');

#program logik
my $conf_file = '';
if (defined @ARGV){
	$conf_file = shift;
} else {
	$conf_file = $main->FBox(-filter => '*.conf')->Show
		or &cmd_end("Need a config file");
}

my ($folder, $logconfig, $urls) = YAML::LoadFile($conf_file);

chomp $folder;
chomp $logconfig;

$folder_in->insert(0, $folder);
$logfile_in->insert(0, $logconfig);

foreach (@$urls) {
   $box->insert('end', $_);
   }

MainLoop;

sub cmd_end {
	my $anwser = shift;
	$main->messageBox(-message=>$anwser);
	exit;
}

sub save_file {
	my @elements = $box->get(0, 'end');
	YAML::DumpFile($conf_file,($folder_in->get(), $logfile_in->get(), \@elements));
	$main->messageBox(-message=>"successfull Saved!");
}

sub eingabe_bearbeiten {
  my $popup = $main->Toplevel;
  $popup->Label("-text" => "Neue URL")->pack;
  my $eingabe = $popup->Entry();
  $eingabe->pack();
  $popup->Button("-text" => "Add",
		 "-command" =>sub{ $box->insert('end', $eingabe->get); $popup->destroy;})->pack;
}
