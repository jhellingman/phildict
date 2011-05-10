# KVED-sort.pl -- sort the entries of KVED.

use strict;

my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");


my $entryId = 0;
my @entries = ();

while (<INPUTFILE>)
{
    my $line = $_;

    if ($line =~ /<entry\b(.*?)>/) 
    {
        collectEntry();
    }
}

print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
print "<dictionary lang=\"en\">\n";
print "<div1><head>VISAYAN-ENGLISH&#xA0;DICTIONARY (KAPUL⁄NGAN&#xA0;BINISAY¡-ININGLÕS)</head>\n";
print "<col>\n";


use sort 'stable';

@entries = sort {beforeTripleHash($a) cmp beforeTripleHash($b)} @entries;

my $letter = '@';
my $openDiv = 0;

foreach my $entry (@entries)
{
    my $firstLetter = substr($entry, 0, 1);
    $entry =~ /\#\#\#/;
    $entry = $';

    if ($letter ne $firstLetter) 
    {
        if ($openDiv == 1) 
        {
            print "</div2>\n";
        }
        print "<div2>\n";
        $openDiv = 1;
        print "<head>" . uc($firstLetter) . "</head>\n\n";
        $letter = $firstLetter;
    }

    print "<entry>\n$entry</entry>\n"; 
}
if ($openDiv == 1) 
{
    print "</div2>\n";
}


print "</col></div1></dictionary>\n";



sub beforeTripleHash($)
{
    my $str = shift;
    $str =~ /\#\#\#/;
    $str = $`;
    return lc($str);
}



sub collectEntry()
{
    my $entry = "";

    while (<INPUTFILE>)
    {
        my $line = $_;
        if ($line =~ /<\/entry>/) 
        {
            last;
        }
        $entry .= $line;
    }

    handleEntry($entry);
    $entryId++;
}



sub handleEntry($)
{
    my $entry = shift;
    my $remainder = $entry;
    if ($entry =~ /<hw>(.*?)<\/hw>/)
    {
        my $headword = $1;
        $entry = stripSpecials($headword) . "###" . $entry;
    }

    print STDERR ".";

    push (@entries, $entry);
}



sub stripSpecials($)
{
    my $word = shift;

    $word = stripXmlTags($word);
    $word = lc($word);

    $word =~ s/[ .,:;()-]//g;
    $word =~ s/[·‡‚A¡¿¬]/a/g;
    $word =~ s/[ÈËÍE…» ]/e/g;
    $word =~ s/[ÌÏÓIÕÃŒ]/i/g;
    $word =~ s/[ÛÚÙO”“‘]/o/g;
    $word =~ s/[˙˘˚U⁄Ÿ€]/u/g;
    $word =~ s/[Ò—]/n/g;

    return $word;
}


sub stripXmlTags($)
{
    my $string = shift;
    $string =~ s/<\/?[a-z]+(.*?)>//g;
    return $string;
}
