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
	
	$self->{dsn} = "DBI:CSV:f_dir=$self->{podcastdb}";
    	
	if(! -f File::Spec->catfile($self->{podcastdb},$self->{dbname})) {
        	$self->db_init();
    	}

	if(! $self->{dbh} ) {
		$self->{dbh} = $self->dbh();
	}
	
	return $self;
}

###########################################
sub dbh {
###########################################
    my($self) = @_;
 
    if(! $self->{dbh} ) {
        $self->{dbh} = DBI->connect($self->{dsn});
    }
 
    return $self->{dbh};
}

###########################################
sub db_init {
###########################################
	my ($self) = @_;
	my ($podcastdb, $dbname) = ($self->{podcastdb}, $self->{dbname});
	unless (-e $podcastdb){
		mkdir $podcastdb;
	}
        my $dbh = $self->dbh()
                or die "Cannot connect: $DBI::errstr";
        my $sth = $dbh->prepare("CREATE TABLE $dbname (title VARCHAR(30), channel VARCHAR(30), folder VARCHAR(30), path VARCHAR(60), date VARCHAR(40))");
        $sth->execute or die "Cannot execute: " . $sth->errstr ();
        $sth->finish;

        return 1;
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
