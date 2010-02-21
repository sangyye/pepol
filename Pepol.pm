package Pepol;
use strict;
use Exporter;
use DBI;
use File::Spec;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 1.00;
@ISA         = qw(Exporter);
@EXPORT      = ();
@EXPORT_OK   = qw(connect_db in_db disconnect_db);
%EXPORT_TAGS = ( DEFAULT => [qw(&connect_db &in_db &disconnect_db)],
                 Both    => [qw(&connect_db &in_db &disconnect_db)]);

sub connect_db {
	my ($podcastdb, $dbname) = @_;
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

sub disconnect_db {
	my($dbh) = shift;
	$dbh->disconnect;
}

sub add_podcast {
        my ($dbh,$dbname, $title, $channel, $folder, $path) = @_;
        my $time = localtime;
        $dbh->do("INSERT INTO $dbname VALUES (?,?,?,?,?)", undef, $title, $channel, $folder, $path, $time);
}

sub in_db{
        my ($dbh,$dbname, $title) = @_;
        my $sth = $dbh->prepare("SELECT title FROM $dbname WHERE title=?");
        $sth->execute($title);
        while (my @row = $sth->fetchrow_array) {
                if ($row[0] eq $title) {
                        return 1;
                }
        }
        return 0;
}

1;
