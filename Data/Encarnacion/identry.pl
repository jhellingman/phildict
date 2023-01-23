# identry.pl

use strict;
use warnings;

use Unicode::Normalize;

my $inputFile = $ARGV[0];
my $pageNumber = 0;
my $elementNumber = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Adding ids to $inputFile\n";


# <p>Abadía. =    ->  <p id=e.abadia>

while (<INPUTFILE>) {
    my $line = $_;
    if ($line =~ m/<p>([a-záéíóúàèìòùâêîôûñ ]+)(,[,a-záéíóúàèìòùâêîôûñ ]+)?\. [=]/i) {
        my $before = $`;
        my $entry = $1;
        my $afterComma = $2;
        my $after = $';

        if (!defined $afterComma) {
            $afterComma = '';
        }

        my $newId = makeId($entry);

        print "$before<p id=e.$newId>$entry$afterComma. =$after";
    } else {
        print $line;
    }
}


sub makeId {
    my $entry = shift;
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



