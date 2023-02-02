# identry.pl

use strict;
use warnings;

use Unicode::Normalize;

my $inputFile = $ARGV[0];
my $pageNumber = 0;
my $elementNumber = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Adding refs to $inputFile\n";


# V. Abadía. =  ->  V> <ref target=e.abadia>Abadía</ref>.

while (<INPUTFILE>) {
    my $remainder = $_;
    my $result = "";
    while ($remainder =~ m/((?:<corr.*?>)?V\.(?:<\/corr>)? <hi>)([a-záéíóúàèìòùâêîôûñ ]+)(<\/hi>)/i) {
        my $before = $`;
        my $start = $1;
        my $vide = $2;
        my $end = $3;
        $remainder = $';

        my $newId = makeId($vide);

        $result .= "$before$start<ref target=e.$newId>$vide</ref>$end";
    }

    while ($remainder =~ m/(, <hi>)([a-záéíóúàèìòùâêîôûñ ]+)(<\/hi>)/i) {
        my $before = $`;
        my $start = $1;
        my $vide = $2;
        my $end = $3;
        $remainder = $';

        my $newId = makeId($vide);
        $result .= "$before$start<ref target=e.$newId>$vide</ref>$end";
    }

    print $result . $remainder;
}


sub makeId {
    my $entry = shift;
    $entry =~ s/[ñÑ]/ny/;
    my $newId = stripDiacritics(lc($entry));

    $newId =~ s/ /./g;            ## replace spaces with dots
    if (length($newId) > 20) {
        my $i = rindex($newId, ".", 20);
        if ($i != -1) {
            $newId = substr($newId, 0, $i);
        } else {
            $newId = substr($newId, 0, 20);
        }
    }
    return $newId;
}


#
# stripDiacritics
#
sub stripDiacritics {
    my $string = shift;

    for ($string) {
        $_ = NFD($_);       ## decompose (Unicode Normalization Form D)
        s/\pM//g;           ## strip combining characters
    }
    return $string;
}



