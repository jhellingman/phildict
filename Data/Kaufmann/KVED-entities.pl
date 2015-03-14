# KVED-entities.pl -- add tagging to Kaufmann's Visayan-English Dictionary

use strict;

my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");


while (<INPUTFILE>)
{
    my $line = $_;

    $line =~ s/\&Ntilde;G/NG/sg;
    $line =~ s/\&Gtilde;/G/sg;
    $line =~ s/\&ntilde;g/ng/sg;
    $line =~ s/\&gtilde;/g/sg;

    $line =~ s/\&ait;/\&agrave;/sg;
    $line =~ s/\&aacit;/\&acirc;/sg;

    $line =~ s/\&eit;/\&egrave;/sg;
    $line =~ s/\&eacit;/\&ecirc;/sg;

    $line =~ s/\&iit;/\&igrave;/sg;
    $line =~ s/\&iacit;/\&icirc;/sg;

    $line =~ s/\&oit;/\&ograve;/sg;
    $line =~ s/\&oacit;/\&ocirc;/sg;

    $line =~ s/\&uit;/\&ograve;/sg;
    $line =~ s/\&uacit;/\&ocirc;/sg;

    # Some shorthand elements
    $line  =~ s/<b>/<hi rend=\"bold\">/sg;
    $line  =~ s/<\/b>/<\/hi>/sg;

    print $line;
}
