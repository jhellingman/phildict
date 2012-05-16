# process.pl -- process the Wolff dictionary.

use strict;

my $xsldir  = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon   = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar "; # (see http://saxon.sourceforge.net/)

my $letter = $ARGV[0];

if ($letter ne '') 
{
    processLetter($letter);
}
else
{
    processAll();
}

sub processAll
{
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
    system ("$saxon WCED-collect.xsl WCED-collect.xsl > WCED-structural.xml");
    system ("$saxon WCED-structural.xml WCED-db.xsl > output/WCED-db.sql");
    system ("perl toEntities.pl output/WCED-db.sql > output/WCED-db-ent.sql");
}

sub processLetter
{
    my $letter = shift;

    # system ("perl WCED-downtag.pl WCED-$letter.tei > WCED-typo-$letter.tei");
    # system ("perl -S tei2html.pl WCED-typo-$letter.tei 2> tmp-$letter.err");

    system ("perl -S tei2html.pl -x WCED-$letter.tei 2> tmp.err");
    system ("$saxon WCED-$letter.xml WCED-uptag2.xsl > structural-$letter.xml");
    system ("$saxon structural-$letter.xml WCED-view.xsl > output/structural-$letter.html");

    # Generate SQL
    system ("$saxon structural-$letter.xml WCED-db.xsl > output/WCED-db-$letter.sql");
    system ("perl toEntities.pl output/WCED-db-$letter.sql > output/WCED-db-ent-$letter.sql");

    # Generate HTML similar to original typography.
    system ("$saxon WCED-$letter.xml WCED-downtag.xsl > output/typographical-$letter.xml");
}
