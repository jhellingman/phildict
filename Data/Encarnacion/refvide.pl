# identry.pl

use strict;
use warnings;

use Unicode::Normalize;

my $inputFile = $ARGV[0];
my $pageNumber = 0;
my $elementNumber = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Adding refs to $inputFile\n";


# V. Abad�a. =    ->  V> <ref target=e.abadia>Abad�a</ref>.

while (<INPUTFILE>) {
    my $line = $_;
    while ($line =~ m/((?:<corr.*?>)?V\.(?:<\/corr>)? <hi>)([a-z���������������� ]+)(<\/hi>)/i) {
        my $before = $`;
        my $start = $1;
        my $vide = $2;
        my $end = $3;
        $line = $';

        my $newId = makeId($vide);

        print "$before$start<ref target=e.$newId>$vide</ref>$end";
    }
    print $line;
}


sub makeId {
    my $entry = shift;
    $entry =~ s/[��]/ny/;
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



