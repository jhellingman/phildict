# WCED-text.pl -- Convert WCED to plain vanilla Unicode text

use strict;

use Text::Wrap;

use SgmlSupport qw/getAttrVal sgml2utf/;

binmode(STDOUT, ":utf8");
# use open ':utf8';

$Text::Wrap::columns = 72;

my $tagPattern = "<(.*?)>";

while (<>) {
    my $a = $_;

    # remove TeiHeader
    if ($a =~ /<[Tt]ei[Hh]eader/) {
        $a = $';
        while($a !~ /<\/[Tt]ei[Hh]eader>/) {
            $a = <>;
        }
        $a =~ /<\/[Tt]ei[Hh]eader>/;
        $a = $';
    }

    # drop comments from text (replace with single space).
    $a =~ s/<!--.*?-->/ /g;
    # warn for remaining comments
    $a =~ s/<!--/[ERROR: unhandled comment start]/g;

    # Clothe sense numbers in braces to make them more clear in plain (Unicode) text
    $a =~ s/<number>([a-z0-9]+)<\/number>/<number>\{\1\}<\/number>/g;

    # prevent unwanted breaks:
    $a =~ s/<\/number> /<\/number>~/g;
    $a =~ s/<\/pos> /<\/pos>~/g;

    $a = sgml2utf($a);

    $a = handleSub($a);

    # remove any remaining tags
    $a =~ s/<.*?>//g;

    # warn for entities that slipped through.
    if ($a =~ /\&([a-zA-Z0-9._-]+);/) {
        my $ent = $1;
        if (!($ent eq "gt" || $ent eq "lt" || $ent eq "amp")) {
            print "\n[ERROR: Contains unhandled entity &$ent;]\n";
        }
    }

    # remove the last remaining entities
    $a =~ s/\&gt;/>/g;
    $a =~ s/\&lt;/</g;
    $a =~ s/\&amp;/&/g;

    $a = wrapLine($a);

    # Remove the non-breaking spaces introduced above.
    $a =~ s/~/ /g;

    print $a;
}

sub wrapLine($) {
    my $line = shift;
    $line =~ /^(.*)(\n*)$/;
    $line = $1;
    my $ending = $2;
    $line = wrap("", "", $line);
    return $line . $ending;
}

sub handleSub($) {
    my $remainder = shift;
    my $a = "";
    while ($remainder =~ /<sub>(.*?)<\/sub>/) {
        $a .= $` . "_" . $1;
        $remainder = $';
    }
    return $a . $remainder;
}
