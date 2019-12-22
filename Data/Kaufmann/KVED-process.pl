# process.pl -- Process Kaufmann's Visayan-English Dictionary files.

use strict;

my $toolsdir    = "../../../../eLibrary/Tools/tei2html/tools";          # location of tools (see https://github.com/jhellingman/tei2html)
my $princedir   = "D:\\Program Files (x86)\\Prince\\engine\\bin";       # location of prince processor (see http://www.princexml.com/download/)
my $jardir      = "../../../../eLibrary/Tools/tei2html/tools/lib";
my $saxon       = "java -jar $jardir/saxon9he.jar ";                    # (see http://saxon.sourceforge.net/)


my $frontFile = "KVED-Introduction-0.2.tei";
my $bodyFile = "KVED-Body-0.1.txt";

# Preprocess front
system ("perl KVED-entities.pl $frontFile > KVED-Introduction.tei");

# Preprocess body
system ("perl $toolsdir/catpars.pl $bodyFile > temp-01.txt");
system ("perl KVED-tei.pl temp-01.txt > temp-02.tei");
system ("perl KVED-entities.pl temp-02.tei > KVED-Body.tei");

# Combine front and body and process result
system ("perl KVED-include.pl KVED-Introduction.tei > KVED.tei");
system ("perl -S tei2html.pl -h -v -r KVED.tei");

# Add tagging for database and Prince processing
system ("perl KVED-tag.pl temp-01.txt > temp-02.xml");

# Sort entries
system ("perl KVED-sort.pl temp-02.xml > temp-02s.xml");

# Create PDF format (This may take up to 30 minutes)
# system ("\"$princedir/prince\" -s KVED-Prince3.css temp-02s.xml KVED-body.pdf");

# Create database format
system ("perl KVED-db.pl temp-02.xml");

# Create database if needed
if (!-e "SQL/dictionary_database") {
    system ("sqlite3 SQL/dictionary_database < SQL/structure-sqlite.sql");
    system ("sqlite3 SQL/dictionary_database < SQL/kved_sqlite.sql");
}

# Convert to simple XDXF
system ("$saxon KVED.xml dic2xdxf.xsl > KVED-xdxf.xml");
