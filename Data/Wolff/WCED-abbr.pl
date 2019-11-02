# WCED-abbr.pl -- Handle abbreviations in WCED files in {...|...} notation.

use strict;

while (<>) {
    my $line = $_;
    $line = handleAbbreviations($line);

    # Handle &apos; (temporarily, for checks only)
    # $line =~ s/\&apos;/&mlapos;/sg;

    print $line;
}

sub handleAbbreviations($) {
    my $remainder = shift;

    # Recognize @-tagged translations first
    $remainder =~ s/[@]([A-Za-z-]+)/<tr>\1<\/tr>/sg;
    $remainder =~ s/[@]\{([^}]*)\}/<tr>\1<\/tr>/sg;

    my $result = '';
    while ($remainder =~ /\{(.*?)\|(.*?)\}/) {
        $result .= $`;
        my $abbr = $1;
        my $expan = $2;
        $remainder = $';

        if ($abbr eq '') {
            print "\n[ERROR: empty abbreviation]\n";
            print STDERR "ERROR: empty abbreviation\n";
        }

        if ($expan eq '') {
            print "\n[ERROR: empty expansion]\n";
            print STDERR "ERROR: empty expansion\n";
        }

        $result .= "<abbr type='lemma' expan='$expan'>$abbr</abbr>";
    }

    $result .= $remainder;
    return $result;
}