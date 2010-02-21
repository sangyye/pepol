package Pepol;
###########################################
use strict;
use warnings;
use DBI;
use File::Spec;

our $VERSION = "0.6";

###########################################
sub new {
###########################################
	my($class, %options) = @_;
	
	my $self = {
		%options,
	};
	bless $self, $class;
	
	if(! $self->{dbh} ) {
		$self->{dbh} = $self->connect_db();
	}
	
	return $self;
}

###########################################
sub connect_db {
###########################################
	my ($self) = @_;
	my ($podcastdb, $dbname) = ($self->{podcastdb}, $self->{dbname});
	unless (-e $podcastdb){
		mkdir $podcastdb;
	}
        my $dbh = DBI->connect("DBI:CSV:f_dir=$podcastdb")
                or die "Cannot connect: $DBI::errstr";
        unless (-e File::Spec->catfile($podcastdb,$dbname)) {
                my $sth = $dbh->prepare("CREATE TABLE $dbname (title VARCHAR(30), channel VARCHAR(30), folder VARCHAR(30), path VARCHAR(60), date VARCHAR(40))");
                $sth->execute or die "Cannot execute: " . $sth->errstr ();
                $sth->finish;
        }
        return $dbh;
}

###########################################
sub add_podcast {
###########################################
        my ($self, $title, $channel, $folder, $path) = @_;
        my $time = localtime;
        my $dbh = $self->{dbh};
	$dbh->do("INSERT INTO $self->{dbname} VALUES (?,?,?,?,?)", undef, $title, $channel, $folder, $path, $time);
}

###########################################
sub in_db{
###########################################
        my ($self, $title) = @_;
        my $sth = $self->{dbh}->prepare("SELECT title FROM $self->{dbname} WHERE title=?");
        $sth->execute($title);
        while (my @row = $sth->fetchrow_array) {
                if ($row[0] eq $title) {
                        return 1;
                }
        }
        return 0;
}

1;
