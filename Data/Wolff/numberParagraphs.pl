# numberParagraphs.pl -- number the paragraphs in a document.

use strict;
use Roman;          # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

my $inputFile   = $ARGV[0];
my $parNumber   = $ARGV[1];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

while (<INPUTFILE>) {
    my $line = $_;

    my $remainder = $line;

    while ($remainder =~ m/<p\b(.*?)>/) {
        my $before = $`;
        my $attrs = $1;
        $remainder = $';
        $parNumber++;

        $attrs = $attrs . " id=$parNumber";

        print "$before<p$attrs>";
    }
    print $remainder;
}

print STDERR $parNumber;
