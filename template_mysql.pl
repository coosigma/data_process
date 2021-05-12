#!/bin/perl

# load module
use DBI;

# connect
my $dbh = DBI->connect("DBI:mysql:database=mydb;host=localhost", "perler", "777", {'RaiseError' => 1});

# execute INSERT query
#my $rows = $dbh->do("INSERT INTO users (id, username, country) VALUES (4, 'jay', 'CZ')");
#print "$rows row(s) affected ";

# execute SELECT query
my $sth = $dbh->prepare("SELECT username, country FROM users");
$sth->execute();

# iterate through resultset
# print values
while(my $ref = $sth->fetchrow_hashref()) {
    print "User: $ref->{'username'} ";
    print "Country: $ref->{'country'} ";
    print "\n----------\n";
}

# clean up
$dbh->disconnect();
