# WCED-db.pl -- create database structure from WCED xml file.

use strict;

use XML::LibXML;

require Encode;
use Unicode::Normalize;
use DBI;

# use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

my $prefix = "wced_";
my $pageNum = 0;
my $nextPageNum = 0;
my $entryId = 0;
my $wordId = 0;

my %wordHash = ();


main();


sub main()
{
    my $infile = $ARGV[0];

    open (ENTRY,        ">entry.sql")       || die ("Could not create output file 'entry.sql'");
    open (WORD,         ">word.sql")        || die ("Could not create output file 'word.sql'");
    open (WORDENTRY,    ">wordentry.sql")   || die ("Could not create output file 'wordentry.sql'");

    my $dom = XML::LibXML->load_xml(location => $infile);
    my @entries = $dom->findnodes("/dictionary/entry");

    foreach my $entry (@entries) 
    {
        handleEntry($entry);
    }
}


#
# handleEntry() -- print the SQL statement for an entry.
#
sub handleEntry($)
{
    my $entry = shift;

    my $entryId = $entry->find('@id')->to_literal;

    print ENTRY "INSERT INTO `" . $prefix . "entry` VALUES ($entryId, " .
        quoteSql($entry->toString()) .
        ", " . $pageNum .
        ");\n";
}


#
# quoteSql() -- quote a string for inclusion into a SQL query.
#
sub quoteSql($)
{
    my $field = shift;
    $field =~ s/\"/\"\"/g;
    return "\"$field\"";
}
