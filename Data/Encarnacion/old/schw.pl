# schw.pl

use strict;
use warnings;

use Unicode::Normalize;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Adding markup to $inputFile\n";


# <p id=e.abadia>Abad�a. = -><p id=e.abadia><hi rend=sc>Abad�a.</hi>

while (<INPUTFILE>) {
    my $line = $_;
    if ($line =~ m/(<p id=[a-z.]+>)([a-z���������������� ]+)(,[,a-z���������������� ]+)?(\. (?:<corr.*?>)?(?:V\.|[=])(?:<\/corr>)?)/i) {
        my $before = $`;
        my $ptag = $1;
        my $entry = $2;
        my $afterComma = $3;
        my $connector = $4;
        my $after = $';

        if (!defined $afterComma) {
            $afterComma = '';
        }

        print "$before$ptag<hi rend=sc>$entry</hi>$afterComma$connector$after";
    } else {
        print $line;
    }
}

