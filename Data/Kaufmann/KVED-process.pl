# process.pl -- Process Kaufmann's Visayan-English Dictionary files.

use strict;

my $toolsdir    = "../../../../eLibrary/Tools/tei2html/tools";          # location of tools (see https://github.com/jhellingman/tei2html)
my $princedir   = "D:\\Program Files (x86)\\Prince\\engine\\bin";       # location of prince processor (see http://www.princexml.com/download/)
my $jardir      = "../../../../eLibrary/Tools/tei2html/tools/lib";
my $saxon       = "java -jar $jardir/saxon9he.jar ";                    # (see http://saxon.sourceforge.net/)


my $frontFile = "KVED-Introduction-0.2.tei";
my $bodyFile = "KVED-Body-0.1.txt";

print "Front...\n";

system ("perl KVED-entities.pl $frontFile > KVED-Introduction.tei");

print "Body...\n";

print "Concatenate paragraphs...\n";
system ("perl $toolsdir/catpars.pl $bodyFile > temp-01.txt");

print "Add tagging for TEI processing...\n";
system ("perl KVED-tei.pl temp-01.txt > temp-02.tei");
system ("patc -p $toolsdir/win2sgml.pat temp-02.tei temp-03.tei");
system ("perl KVED-entities.pl temp-03.tei > KVED-Body.tei");

print "Combine Front and Body...\n";
system ("perl KVED-include.pl KVED-Introduction.tei > KVED.tei");
system ("perl -S tei2html.pl -h KVED.tei");

print "Add tagging for DB and Prince processing...\n";
system ("perl KVED-tag.pl temp-01.txt > temp-02.xml");

print "Sort entries...\n";
system ("perl KVED-sort.pl temp-02.xml > temp-02s.xml");

# print "Create PDF format... (This may take up to 30 minutes)\n";
# system ("\"$princedir/prince\" -s KVED-Prince3.css temp-02s.xml KVED-body.pdf");

print "Create database format...\n";
system ("perl KVED-db.pl temp-02.xml");

# Create database if needed
if (!-e "SQL/dictionary_database") 
{
    system ("sqlite3 SQL/dictionary_database < SQL/structure-sqlite.sql");
    system ("sqlite3 SQL/dictionary_database < SQL/kved_data.sql");
}

print "Report on word usage...\n";
system ("perl $toolsdir/win2utf8.pl temp-02.xml > KVED-dictionary.xml");
system ("perl $toolsdir/ucwords.pl  KVED-dictionary.xml > words.html");

print "Convert to simple XDXF...\n";
system ("$saxon KVED-dictionary.xml dic2xdxf.xsl > KVED-xdxf.xml");
