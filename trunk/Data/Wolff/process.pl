use strict;

my $xsldir  = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon   = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar "; # (see http://saxon.sourceforge.net/)

my $filename = $ARGV[0];
my $stylesheet = $ARGV[1];



# system ("perl WCED-uptag1.pl part6.tei > part6-ut.tei");
# system ("perl -S tei2html.pl -x part6-ut.tei");
# system ("$saxon part6-ut.xml WCED-uptag2.xsl > output.xml");
# system ("$saxon output.xml WCED-view.xsl > structural.html");

system ("perl -S tei2html.pl -x WCED-frontmatter-0.1.tei");

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

system ("$saxon WCED-complete.xsl WCED-complete.xsl > WCED-complete.xml");
system ("perl -S tei2html.pl WCED-complete.xml");

# system ("$saxon WCED-body.xml WCED-uptag2.xsl > output.xml");
# system ("$saxon output.xml WCED-view.xsl > structural.html");

# system ("$saxon WCED-body.xml WCED-downtag.xsl > typographical.xml");

# system ("$saxon output.xml WCED-db.xsl");


sub processLetter
{
    my $letter = shift;

    system ("perl -S tei2html.pl -x WCED-$letter.tei 2> tmp.err");
    system ("$saxon WCED-$letter.xml WCED-uptag2.xsl > tmp.xml");
    system ("$saxon tmp.xml WCED-view.xsl > structural-$letter.html");
    system ("$saxon WCED-$letter.xml WCED-downtag.xsl > typographical-$letter.xml");
}
