#!/usr/bin/perl
use warnings;
use strict;
use Tk;
use Tk::FBox;
require Tk::Dialog;
use YAML qw(LoadFile DumpFile);

local $YAML::UseHeader = 0;
#Grafische Oberfläche generieren

my $main = MainWindow->new(-title => "Pepol URL-Adder");
my $menu_bar = $main->Frame(-relief => 'groove', -borderwidth=>1);
my $menu_fb = $menu_bar->Menubutton(-text => 'File');
my $menu_hb = $menu_bar->Menubutton(-text => 'Help');

#menu file
$menu_fb->command(-label=>'Load Config', -command=> sub{&load_file($main->FBox(-filter => '*.conf')->Show)});
$menu_fb->command(-label=>'Save', -command=> sub{&save_file});
$menu_fb->command(-label=>'Edit Config', -command=> sub{&edit_config});
$menu_fb->separator();
$menu_fb->command(-label=>'Exit', -command=> sub{$main->destroy});
$menu_fb->separator();
#menu_help
$menu_hb->command(-label=>'About', -command=>\&about_txt );
$menu_hb->command(-label=>'Help', -command=>\&help_txt);
$menu_hb->separator();

$menu_fb->pack(-side => 'left');
$menu_hb->pack(-side => 'right');
$menu_bar->pack(-side => 'top',-fill=>'x');
my $title_frame= $main->Frame();
$title_frame->Label(-text => "Urls")->pack();
$title_frame->pack(-side=>'top');
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

$bt_add->pack(-side => 'left');
$bt_remove->pack(-side => 'left');

#program logik
my $conf_file = '';
if (defined @ARGV){
	$conf_file = shift;
} else {
	$conf_file = $main->FBox(-filter => '*.conf')->Show
		or &cmd_end("Need a config file");
}

my $popup_in1 = "";
my $popup_in2 = "";
my $yaml;

&load_file($conf_file);

MainLoop;

#some functions
sub load_file {
	my $confile = shift;
	$yaml = YAML::LoadFile($confile);
	
	$box->delete(0, 'end');

	foreach (@{$yaml->{urls}}) {
   	$box->insert('end', $_);
   	}	
}

sub cmd_end {
	my $anwser = shift;
	my $popup=$main->DialogBox(-title=>"End", -buttons=>["OK"],-command=>sub{exit;});
        $popup->add("Label", -text=>$anwser)->pack;
        $popup->Show;
}

sub edit_config {
	my $popup=$main->DialogBox(-title=>"Edit Config", -buttons=>["OK","Cancel"], -command=>sub{my $i= shift; if($i eq "OK"){$yaml->{dir} = $popup_in1->get();$yaml->{logfile}=$popup_in2->get();}});
        $popup->add("Label", -text=>"Podcast:")->grid(-row =>0, -column=>0);
	$popup_in1 =$popup->add("Entry", -width=>'25')->grid(-row =>0, -column=>1);
	$popup_in1->insert('0',$yaml->{dir});
	$popup->add("Label", -text=>"Log-File:")->grid(-row =>1, -column=>0);
	$popup_in2 = $popup->add("Entry", -width=>'25')->grid(-row =>1, -column=>1);
	$popup_in2->insert('0', $yaml->{logfile});
        $popup->Show;
}

sub save_file {
	my @urls = $box->get(0, 'end');
	my $hash = {};
	$hash->{'dir'} = $yaml->{dir};
	$hash->{'logfile'} = $yaml->{logfile};
	$hash->{'urls'} = \@urls;
	YAML::DumpFile($conf_file, $hash);
	my $popup=$main->DialogBox(-title=>"Save", -buttons=>["OK"],);
        $popup->add("Label", -text=>"Successfull Saved!")->pack;
        $popup->Show;
}

sub eingabe_bearbeiten {
	my $popup = $main->Toplevel;
	$popup->Label("-text" => "Neue URL")->pack;
	my $eingabe = $popup->Entry();
	$eingabe->pack();
	$popup->Button("-text" => "Add",
		       "-command" =>sub{ $box->insert('end', $eingabe->get); $popup->destroy;})->pack;
}
#DBI sachen


#a little help
sub about_txt {
        my $popup=$main->DialogBox(-title=>"ABOUT", -buttons=>["OK"],);
        $popup->add("Label", -text=>"Pepol URL-Adder\nversion 0.5\nby abakus")->pack;
        $popup->Show;
}

sub help_txt {
        my $popup=$main->DialogBox(-title=>"HELP", -buttons=>["OK"],);
        $popup->add("Label", -text=>"lol, why do you need help?!\nfor more infos:\njava5\@arcor.de",)->pack;
        $popup->Show;
}


