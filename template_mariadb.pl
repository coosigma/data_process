##################################################
# Usage: Import <csv> into Database
# Version: 0.1
# Author: Bing Liang
# Date: 12 May 2021
##################################################

use warnings FATAL => 'all';
use strict;
use Getopt::Long;
use Data::Dumper;
use autodie;
use DBI;

# DB related Variables
my $driver   = "MariaDB";
my $host     = "localhost";
my $database = "clinical_data";
my $user     = "root";
my $passwd   = "root";
my $port     = 3306;

# Receive Paramters
my ( $csv_file, $into_table );

GetOptions(
    'csv=s'   => \$csv_file,
    'table=s' => \$into_table,
);

# Connect to DB
my $begin = time();
my $dbh   = DBI->connect( "dbi:$driver:dbname=$database;host=$host;port=$port",
    $user, $passwd, { RaiseError => 1, AutoCommit => 0 } )
  or die $DBI::errstr;

&main( $csv_file, $into_table, $dbh );

# Subroutines #############################

sub main {

    my ( $inp, $table, $dbh ) = @_;
    my %label;
    my $sth;
    my $i_row;

    open my $csv, '<', $inp;

    while (<$csv>) {

        chomp;

        my @column   = split( /\t/, $_ );
        my @text_col = map { "\"$_\"" } @column;

        if ( $column[0] !~ /^(\d|-)/ ) {
            &label2pos( \@column, \%label );
            my $values  = "?" . ( ",?" x $#column );
            my $columns = join( ",", @text_col );
            $sth =
              $dbh->prepare("INSERT INTO $table($columns) VALUES ($values)")
              or die "Syntax error:$!\n";
            print "Processed Header line\n";
            next;
        }

        $sth->execute(@column)
          or ( die "cannot execute:$!/n" and $dbh->rollBack );

        $i_row++;
        print "Processed the ${i_row}th Row。\n";

    }

    close $csv;
    $sth->finish();
    $dbh->commit;
    $dbh->disconnect;

    my $finish = time();

    my ( $hour, $min, $sec ) = time_cost( $begin, $finish );

    print "\nTotal Time: ${hour}h${min}m${sec}s。\n";

}

# others

sub label2pos {

    my ( $col_ref, $lab_ref ) = @_;

    for my $i ( 0 .. $#{$col_ref} ) {
        $lab_ref->{ $col_ref->[$i] } = $i;
    }

}

sub time_cost {

    my ( $bigen, $finish ) = @_;

    my $diff_time = $finish - $bigen;

    my $hour = $diff_time / 3600;

    my $min = ( $diff_time % 3600 ) / 60;

    my $sec = ( $diff_time % 3600 ) % 60;

    return ( $hour, $min, $sec );

}
