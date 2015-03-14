# WCED-catpars.pl -- add paragraph tagging to Wolff's Cebuano-English Dictionary

use strict;

my $file = $ARGV[0];
open(INPUTFILE, $file) || die("Could not open input file $file");


my $nextPar = 1;

while (<INPUTFILE>)
{

    if ($_ =~ /-*File: 0*([0-9]+)\.png-*\\([^\\]*)(\\([^\\]+))?(\\([^\\]+))?(\\([^\\]+))?\\.*$/)
    {
        print " <pb n=$1>";
        next;
    }

    if ($_ =~ /^\s*$/)
    {
        $nextPar = 1;
    }
    else
    {
        if ($nextPar == 1)
        {
            print "\n\n<p>";
        }
        $nextPar = 0;
        chomp;
        print;
        print ' ';
    }
}
