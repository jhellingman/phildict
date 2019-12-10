# KVED-include.pl -- Combine parts of Kaufmann's Visayan-English Dictionary

use strict;

my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");

while (<INPUTFILE>) {
    my $line = $_;

    if ($line =~ /<xi:include(.*?)>(.*?)<\/xi:include>/) {
        my $attr = $1;

        my $includedfile = getAttrVal("href", $attr);
        open (INCLUDEDFILE, $includedfile) || die("Could not open input file $includedfile");

        while (<INCLUDEDFILE>) {
            print;
        }

        close INCLUDEDFILE;
    } else {
        print $line;
    }
}

#
# getAttrVal: Get an attribute value from a tag (if the attribute is present)
#
sub getAttrVal($$) {
    my $attrName = shift;
    my $attrs = shift;
    my $attrVal = "";

    if ($attrs =~ /$attrName\s*=\s*(\w+)/i) {
        $attrVal = $1;
    } elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i) {
        $attrVal = $1;
    }
    return $attrVal;
}
