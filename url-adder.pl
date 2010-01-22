#!/usr/bin/perl -w

use strict;
use Tk;
use YAML qw(LoadFile DumpFile);

my $conf_file = shift @ARGV;

my ($folder, $logconfig, $urls) = YAML::LoadFile($conf_file);

my $main = MainWindow->new(-title => "Pepol URL-Edit");
my $frame = $main->Frame(-width => 50, -height => 10);
my $box = $frame->Listbox(-width => 50, -height => 10);

foreach (@$urls) {
   $box->insert('end', $_);
   }

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

my $bt_end = $main->Button("-text" => "End",
                                 "-height" => "1",
                                 "-width"  => "4",
                                 "-command" => sub{ exit;});


$bt_add->pack(-side => 'left');
$bt_remove->pack(-side => 'left');
$bt_end->pack(-side => 'right');
$bt_save->pack(-side =>  'right');

MainLoop;

sub save_file {
	my @elements = $box->get(0, 'end');
	YAML::DumpFile($conf_file,($folder, $logconfig, \@elements));
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
