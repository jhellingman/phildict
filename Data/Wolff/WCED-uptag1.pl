# WCED-tag.pl -- add tagging to Wolff's Cebuano-English Dictionary (version 2, for formatted text)

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

    # Handle (<-) and (->). (Allow for misreading parens and braces)
    $entry =~ s/[{(]<-[)}]/(&larr;)/sg;
    $entry =~ s/[{(]->[)}]/(&rarr;)/sg;

    # Handle &
    # $entry =~ s/\&/\&amp;/sg;

    # Eat extraneous spaces
    $entry =~ s/ +/ /sg;
    $entry =~ s/^ +//;
    $entry =~ s/ +$//;

    # Normalize punctuation around formatting tags (twice, to make them bubble out):
    # $entry =~ s/<\/(i|b|sc)>([.,:;?!])/\2<\/\1>/sg;
    $entry =~ s/([.,:?!])<\/(i|b|sc)>/<\/\2>\1/sg;
    $entry =~ s/([.,:?!])<\/(i|b|sc)>/<\/\2>\1/sg;


    ##### GRAMMAR #####

    # Recognize POS symbols
    $entry =~ s/<i>(a|n|v)<\/i>/<pos>\1<\/pos>/sg;

    # Tag the verb inflection types accordingly. (Note that we accept el for one here)
    $entry =~ s/(\[[ABCabcSNP1-9()]+(; ?[abcSNPl1-9()]+)?\])/<itype>\1<\/itype>/sg;

    # Tag the whole of pos and itype as a gramGrp
    # $entry =~ s/(<pos>(a|n|v)<\/pos>(?: +<itype>[^>]+<\/itype>)?)/<gramGrp>\1<\/gramGrp>/sg;


    ##### MEANING #####

    # Recognize meaning numbers
    my $numberPattern = "(?:[1-9][0-9]*[a-z]?|[a-z])";
    $entry =~ s/<b>(${numberPattern}(, ${numberPattern})*)<\/b>/<number>\1<\/number>/sg;

    # Recognize proofreader's notes
    $entry =~ s/\[\*\*(.*?)\]/<note>\1<\/note>/sg;

    # Recognize @-tagged translations (single word "@abc" and multi word "@{...}")
    $entry =~ s/[@]([A-Za-z-]+)/<tr>\1<\/tr>/sg;
    $entry =~ s/[@]\{([^}]*)\}/<tr>\1<\/tr>/sg;

    # Recognize cross references
    $entry =~ s/(see *|= *)?<sc>([^<]+)<\/sc>(, (?:<pos>[anv]<\/pos> ?)?(?:<number>[0-9]+[a-z]?<\/number>))?/<xr>\1<sc>\2<\/sc>\3<\/xr>/sg;

    # Clear-out pos and numbers within cross references.
    my $remainder = $entry;
    $entry = '';
    while ($remainder =~ /<xr>.*?<\/xr>/) {
        $entry .= $`;
        my $xr = $&;
        $remainder = $';

        $xr =~ s/<\/?gramGrp>//sg;
        $xr =~ s/<pos>/<ix>/sg;
        $xr =~ s/<\/pos>/<\/ix>/sg;
        $xr =~ s/<number>/<bx>/sg;
        $xr =~ s/<\/number>/<\/bx>/sg;
        $entry .= $xr;
    }
    $entry .= $remainder;


    # Normalize bold italic
    $entry =~ s/<i><b>/<b><i>/sg;
    $entry =~ s/<\/b><\/i>/<\/i><\/b>/sg;

    # Then recognize binominal names
    $entry =~ s/<b><i>/<bio>/sg;
    $entry =~ s/<\/i><\/b>/<\/bio>/sg;

    # Remaining bold things should be word-forms
    $entry =~ s/<b>([^<]+)<\/b>/<form>\1<\/form>/sg;

    # Pull punctuation back into italic tags (twice, to make them bubble out):
    $entry =~ s/<\/i>([.,:;?!])/\1<\/i>/sg;
    $entry =~ s/<\/i>([.,:;?!])/\1<\/i>/sg;

    print "$entry";
}
