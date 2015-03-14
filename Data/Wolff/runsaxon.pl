use strict;

my $xsldir  = "../../../../eLibrary/Tools/tei2html";             # location of xsl stylesheets
my $jardir  = "../../../../eLibrary/Tools/tei2html/tools/lib";
my $saxon   = "java -jar $jardir/saxon9he.jar ";        # (see http://saxon.sourceforge.net/)

my $filename = $ARGV[0];
my $stylesheet = $ARGV[1];

system ("$saxon $filename \"$stylesheet\" > output.xml");
