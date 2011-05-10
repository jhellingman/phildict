use strict;


my $xsldir  = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon	= "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar "; # (see http://saxon.sourceforge.net/)

my $filename = $ARGV[0];
my $stylesheet = $ARGV[1];

system ("$saxon $filename \"$stylesheet\" > output.xml");

