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
    
    $self->{dsn} = "dbi:SQLite:dbname=$self->{podcastdb}";
        
    if(! -f $self->{podcastdb}) {
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
        $self->{dbh} = DBI->connect($self->{dsn}, "", "");
    }
 
    return $self->{dbh};
}

###########################################
sub db_init {
###########################################
    my ($self) = @_;
    
    my $dbh = $self->dbh()
            or die "Cannot connect: $DBI::errstr";
    my $sth = $dbh->do("CREATE TABLE podcasts (title TEXT, channel TEXT, folder TEXT, path TEXT, date TEXT)");
    return 1;
}

###########################################
sub add_podcast {
###########################################
    my ($self, $title, $channel, $folder, $path, $time) = @_;
    $time = time unless $time;
    my $dbh = $self->{dbh};
    $dbh->do("INSERT INTO podcasts VALUES (?,?,?,?,?)", undef, $title, $channel, $folder, $path, $time);
}

###########################################
sub in_db {
###########################################
        my ($self, $title) = @_;
        while (my @row = $self->get_podcast($title)) {
                if ($row[0] eq $title) {
                        return 1;
                }
        }
        return 0;
}

###########################################
sub get_all {
###########################################
    my ($self) = @_;
    my @array = ();
    my $sth = $self->{dbh}->prepare("SELECT * FROM podcasts");
    $sth->execute();
    while (my @row = $sth->fetchrow_array) {
        push @array, \@row;
    }
    return @array;
}

###########################################
sub get_podcast {
###########################################
    my ($self, $title) = @_;
    my $sth = $self->{dbh}->prepare("SELECT * FROM podcasts WHERE title=?");
    $sth->execute($title);
    return $sth->fetchrow_array;
}

1;
