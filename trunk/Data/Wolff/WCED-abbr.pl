# WCED-abbr.pl -- Handle abbreviations in WCED files in {...|...} notation.

use strict;

while (<>)
{
    my $a = $_;
    $a = handleAbbreviations($a);
    print $a;
}

sub handleAbbreviations($)
{
    my $remainder = shift;
    my $result = "";
    while ($remainder =~ /\{(.*?)\|(.*?)\}/)
    {
        $result .= $`;
        my $abbr = $1;
        my $expan = $2;
        $remainder = $';

        if ($abbr eq "") 
        {
            print "\n[ERROR: empty abbreviation]\n";
            print STDERR "ERROR: empty abbreviation\n";
        }

        if ($expan eq "") 
        {
            print "\n[ERROR: empty expansion]\n";
            print STDERR "ERROR: empty expansion\n";
        }

        $result .= "<abbr expan='$expan'>$abbr</abbr>";
        
    }

    $result .= $remainder;

    # Recognize @-tagged translations
    $result =~ s/[@]([A-Za-z-]+)/<tr>\1<\/tr>/sg;
    $result =~ s/[@]{([^}]*)}/<tr>\1<\/tr>/sg;

    return $result;
}