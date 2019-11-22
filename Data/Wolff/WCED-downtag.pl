# WCED-downtag.pl

use strict;

my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");

$infile =~ /^([A-Za-z0-9-]*?)\.txt$/;
my $basename = $1;


handleDictionary();


sub handleDictionary() {
    while (<INPUTFILE>) {
        my $line = $_;

        # Start of new entry
        if ($line =~ /^<p>/) {
            handleEntry($line);
        } else {
            print $line;
        }
    }
}


sub handleEntry($) {
    my $entry = shift;

    $entry =~ s/<sub>/<hi rend=sub>/sg;
    $entry =~ s/<\/sub>/<\/hi>/sg;

    $entry =~ s/<asc>/<hi rend=asc>/sg;
    $entry =~ s/<\/asc>/<\/hi>/sg;

    $entry =~ s/<sc>/<hi rend=sc>/sg;
    $entry =~ s/<\/sc>/<\/hi>/sg;

    $entry =~ s/<bio>/<hi><hi rend=bold>/sg;
    $entry =~ s/<\/bio>/<\/hi><\/hi>/sg;

    $entry =~ s/<number>/<hi rend=bold>/sg;
    $entry =~ s/<\/number>/<\/hi>/sg;

    $entry =~ s/<bx?>/<hi rend=bold>/sg;
    $entry =~ s/<\/bx?>/<\/hi>/sg;

    $entry =~ s/<formx?>/<hi rend=bold>/sg;
    $entry =~ s/<\/formx?>/<\/hi>/sg;

    $entry =~ s/<ix?>/<hi>/sg;
    $entry =~ s/<\/ix?>/<\/hi>/sg;

    $entry =~ s/<posx?>/<hi>/sg;
    $entry =~ s/<\/posx?>/<\/hi>/sg;

    $entry =~ s/<[tx]?r>/<hi rend=rm>/sg;
    $entry =~ s/<\/[tx]?r>/<\/hi>/sg;

    $entry =~ s/<itype>/<hi rend=rm>/sg;
    $entry =~ s/<\/itype>/<\/hi>/sg;


    print "$entry";
}
