# process.pl -- Process Wolff's Cebuano-English Dictionary files.

$toolsdir   = "C:\\Users\\Jeroen\\Documents\\eLibrary\\tools\\tei2html\\tools";   # location of tools (see http://code.google.com/p/tei2html/)
# $princedir  = "F:\\Programs\\Prince\\engine\\bin";        # location of prince processor (see http://www.princexml.com/)
my $saxon2 = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";


# processFile2("letter-A.txt", "WCED-A.xml");

# system ("$saxon2 WCED-01.xml WCED-tag3.xsl > test.xml");


processFile("projectID4904c65b1fb34_P3_latest.txt", "WCED-01.xml");
processFile("projectID4904cc5425a6f_P3_latest.txt", "WCED-02.xml");
processFile("projectID4904cc6388000_P3_latest.txt", "WCED-03.xml");
processFile("projectID4904cc703eed2_P3_latest.txt", "WCED-04.xml");
processFile("projectID4904cc7df05c5_P2_latest.txt", "WCED-05.xml");
processFile("projectID4904cc918727b_P1_latest.txt", "WCED-06.xml");
processFile("projectID4904cc9eb99f0_P1_latest.txt", "WCED-07.xml");
processFile("projectID4904ccad4618b_P1_latest.txt", "WCED-08.xml");
processFile("projectID4904ccc7e3ae5_P1_latest.txt", "WCED-09.xml");
processFile("projectID4904ccd44eeb4_P1_latest.txt", "WCED-10.xml");
processFile("projectID4904cce7e1aaa_P1_latest.txt", "WCED-11.xml");
processFile("projectID4904ccf460ed6_P1_latest.txt", "WCED-12.xml");



#
# processFile() -- process a file of the Wolff dictionary.
#
sub processFile($$)
{
    my $fileName = shift;
    my $output = shift;

    $output =~ /^([A-Za-z0-9-]*?)\.xml$/;
    my $basename = $1;

    print "Processing: $fileName\n";

    print "Concatenate paragraphs...\n";
    system ("perl WCED-catpars.pl $fileName > tmp-$basename.txt");
    system ("perl WCED-tag.pl tmp-$basename.txt > $output");

    $output =~ s/\.xml$/.html/;
    system ("perl $toolsdir\\pgpreview.pl $fileName > $output");

    system ("rm tmp-$basename.txt");
}

#
# processFile2() -- process a file of the Wolff dictionary.
#
sub processFile2($$)
{
    my $fileName = shift;
    my $output = shift;

    $output =~ /^([A-Za-z0-9-]*?)\.xml$/;
    my $basename = $1;

    print "Processing: $fileName\n";

    print "Concatenate paragraphs...\n";
    system ("perl WCED-catpars.pl $fileName > tmp-$basename.txt");
    system ("perl WCED-tag2.pl tmp-$basename.txt > $output");

    $output =~ s/\.xml$/.html/;
    system ("perl $toolsdir\\pgpreview.pl $fileName > $output");

    system ("rm tmp-$basename.txt");
}
