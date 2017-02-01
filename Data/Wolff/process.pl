# process.pl -- process the Wolff dictionary.

use strict;

my $xsldir  = "../../../../eLibrary/Tools/tei2html";             # location of xsl stylesheets
my $jardir  = "../../../../eLibrary/Tools/tei2html/tools/lib";
my $saxon   = "java -jar $jardir/saxon9he.jar ";        # (see http://saxon.sourceforge.net/)

my $letter = $ARGV[0];

if ($letter ne '') {
    processLetter($letter);
} else {
    processAll();
}

sub processAll {
    system ("perl -S tei2html.pl -x WCED-frontmatter-0.1.tei");
    system ("perl -S tei2html.pl -x WCED-backmatter-0.0.tei");

    processLetter("A");
    processLetter("B");
    processLetter("D");
    processLetter("G");
    processLetter("H");
    processLetter("I");
    processLetter("K");
    processLetter("L");
    processLetter("M");
    processLetter("N");
    processLetter("P");
    processLetter("R");
    processLetter("S");
    processLetter("T");
    processLetter("U");
    processLetter("W");
    processLetter("Y");
    processLetter("addenda");

    # Generate HTML similar to original typography.
    system ("$saxon WCED-complete.xsl WCED-complete.xsl > WCED-complete.xml");
    system ("perl -S tei2html.pl WCED-complete.xml");

    # Generate PDF version
    system ("perl -S tei2html.pl -p -c=WCED-Prince.css WCED-complete.xml");

    # Generate SQL for database
    system ("$saxon WCED-collect.xsl WCED-collect.xsl > structural/complete.xml");
    system ("$saxon structural/complete.xml WCED-db.xsl > SQL/complete.sql");
    # system ("perl toEntities.pl SQL/complete.sql > SQL/complete-ent.sql");

    # Compress the resulting database
    chdir "SQL";
    system ("zip -Xr9Dq dictionary_database.zip dictionary_database");
    # Smaller possible with: 
    # 7za a -mm=Deflate -mx=9 dictionary_database.zip dictionary_database
    # Even smaller: kzip: http://advsys.net/ken/utils.htm
    chdir "..";
}

sub processLetter {
    my $letter = shift;
    print "Processing letter $letter\n";

    # system ("perl WCED-downtag.pl WCED-$letter.tei > WCED-typo-$letter.tei");
    # system ("perl -S tei2html.pl WCED-typo-$letter.tei 2> tmp-$letter.err");

    system ("perl -S WCED-abbr.pl WCED-$letter.tei > tmp/$letter.tei 2> tmp/$letter.err");

    chdir "tmp";
    system ("perl -S tei2html.pl -x $letter.tei 2> $letter-tei2html.err");
    chdir "..";

    # system ("perl WCED-text.pl WCED-2-$letter.tei > WCED-$letter.txt");
    system ("$saxon tmp/$letter.xml WCED-uptag2.xsl > structural/$letter.xml");
    system ("$saxon structural/$letter.xml WCED-view.xsl > structural/$letter.html");

    # Generate SQL
    system ("$saxon structural/$letter.xml WCED-db.xsl > SQL/$letter.sql");
    # system ("perl toEntities.pl SQL/$letter.sql > SQL/$letter-ent.sql");

    # Create database if needed
    if (!-e "SQL/dictionary_database") {
        print "Recreating database structure\n";
        system ("sqlite3 SQL/dictionary_database < SQL/structure-sqlite.sql");
    }
    # Add to database:
    print "Adding letter $letter to database\n";
    system ("sqlite3 SQL/dictionary_database < SQL/$letter.sql");

    # system ("mv SQL/WCED_head.sql SQL/WCED_head-$letter.sql");

    # Generate HTML similar to original typography.
    system ("$saxon tmp/$letter.xml WCED-downtag.xsl > typographical/$letter.xml");
}
