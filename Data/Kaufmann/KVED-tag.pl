# KVED-tag.pl -- add tagging to Kaufmann's Visayan-English Dictionary

use strict;

my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");


my $useEntities = 0;


handleDictionary();


sub handleDictionary {
    print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
    print "<!DOCTYPE dictionary [\n";
    print "    <!ENTITY mdash \"&#x2014;\">\n";
    print "    <!ENTITY apos \"&#x2019;\">\n";
    print "    <!ENTITY ldquo \"&#x201C;\">\n";
    print "    <!ENTITY rdquo \"&#x201D;\">\n";
    print "]>\n";
    print "<dictionary lang=\"en\">\n";

    while (<INPUTFILE>) {
        my $line = $_;

        # Start of new entry
        while ($line =~ /^<p><b>(.*?)(,?)<\/b>/) {
            my $entry = $line;

            # More lines in entry?
            while (<INPUTFILE>) {
                $line = $_;

                if ($line eq "\n") {
                    next;
                }

                # Old entry ends where new entry starts.
                if ($line =~ /^<p><b>(.*?)(,?)<\/b>/  || $line =~ /^<\/?div[0-9]/) {
                    handleEntry($entry);
                    $entry = $line;
                    last;
                }

                # Close tag <p> of remaining lines:
                if ($line =~ /^<p>/) {
                    my $tail = $';
                    chomp ($tail);
                    $line = "<p>$tail</p>\n";
                    print STDERR ".";
                }

                $entry .= $line;
            }
        }

        # handle unhandled lines.
        handleLine($line);
    }

    print "</dictionary>\n";

    print STDERR "\n";
}


sub handleLine {
    my $line = shift;

    # Turn <pb> tags to XML style tags.
    $line =~ s/<pb n=([0-9]+)>/<pb n=\"\1\"\/>/sg;

    print $line;
}


sub handleEntry {
    my $entry = shift;

    print STDERR "|";

    # print STDERR "handleEntry($entry)\n";

    if ($useEntities == 0) {
        # Get rid of [~g] for now:
        $entry =~ s/\[~g\]/g/sg;
        $entry =~ s/\_a/à/sg;
        $entry =~ s/\_á/â/sg;
        $entry =~ s/\_e/è/sg;
        $entry =~ s/\_é/ê/sg;
        $entry =~ s/\_i/ì/sg;
        $entry =~ s/\_í/î/sg;
        $entry =~ s/\_o/ò/sg;
        $entry =~ s/\_ó/ô/sg;
        $entry =~ s/\_u/ù/sg;
        $entry =~ s/\_ú/û/sg;

        # Also drop the redundant tildes on the ñ in ñg
        $entry =~ s/\ñg/ng/sg;
        $entry =~ s/\Ñg/Ng/sg;

        # Enable line-breaking by inserting a zero-width space.
        $entry =~ s/\&mdash;([A-Za-z])/\&mdash;\&zwsp;\1/sg;

        # Make all entries numeric
        $entry =~ s/\&zwsp;/\&\#x200B;/sg;
        $entry =~ s/\&mdash;/\&\#x2014;/sg;
        $entry =~ s/\&apos;/\&\#x2019;/sg;
        $entry =~ s/\&ldquo;/\&\#x201C;/sg;
        $entry =~ s/\&rdquo;/\&\#x201D;/sg;
        $entry =~ s/\&nbsp;/\&\#xA0;/sg;
    } else {
        $entry =~ s/\[~g\]/\&gtilde;/sg;
        $entry =~ s/\_a/\&ait;/sg;
        $entry =~ s/\_á/\&aacit;/sg;
        $entry =~ s/\_e/\&eit;/sg;
        $entry =~ s/\_é/\&eacit;/sg;
        $entry =~ s/\_i/\&iit;/sg;
        $entry =~ s/\_í/\&iacit;/sg;
        $entry =~ s/\_o/\&oit;/sg;
        $entry =~ s/\_ó/\&oacit;/sg;
        $entry =~ s/\_u/\&uit;/sg;
        $entry =~ s/\_ú/\&uacit;/sg;
    }

    # Remove SGML style comments
    $entry =~ s/<!--.*?-->//sg;

    # Don't care about <corr>...</corr> tags for now
    $entry =~ s/<corr\b.*?>(.*?)<\/corr>/\1/sg;

    # Convert double dollars to <s lang=es> tags
    $entry =~ s/\$\$(.*?)\$\$/<s lang=\"es\">\1<\/s>/sg;

    # Drop redundant dollars.
    $entry =~ s/\$ <pb n=([0-9]+)>\$/ <pb n=\1>/sg;     # around <pb tags>
    $entry =~ s/\$([.,:;()] )\$/\1/sg;                  # around spaces and punctuation

    # Convert single dollars to <s lang=hil> tags
    $entry =~ s/\$(.*?)\$/<s lang=\"hil\">\1<\/s>/sg;

    # Bring sentence-ending punctuation inside the <s> element.
    $entry =~ s/<\/s>([.!?])/\1<\/s>/sg;

    # Turn <pb> tags to XML style tags.
    $entry =~ s/<pb n=([0-9]+)>/<pb n=\"\1\"\/>/sg;

    # Normal entry: <p><b>....,</b>  ->  <hw>....</hw>,
    if ($entry =~ /^<p><b>(.*?)(,?)<\/b>/s) {
        my $headword = $1;
        my $comma = $2;
        my $tail = $';

        $entry = "<entry>\n<hw>$headword</hw>$comma$tail</entry>\n";
    }

    # Spanish derived words:
    $entry =~ s/(\(Sp\. (.*?)\))/<etym>\1<\/etym>/sg;

    # Compare sections:  (cf. ...)
    $entry =~ s/(\(cf\. ([^()]*?)\))/<cf>\1<\/cf>/sg;                       # Do not allow nested parentheses.
    $entry =~ s/(\(cf\. ([^()]*?\([^()]*?\)[^()]*?)\))/<cf>\1<\/cf>/sg;     # Handle one nested set of parentheses.

    # Translations are marked with @...@
    my $partial = '';
    my $remainder = $entry;
    while ($remainder =~ /@(.*?)@/s) {
        $partial .= $`;
        my $translations = $1;
        $remainder = $';
        $partial .= handleTranslations($translations);
    }
    $entry = $partial . $remainder;

    # Cross references are tagged with ^...^
    $entry =~ s/\^(.*?)\^/<ref>\1<\/ref>/sg;

    ######### EXPERIMENTAL

    # Try to recognize example sentences  (<s lang=\"hil\">[A-Z].*?[.!?]</s>) ([A-Z].*?[.!?])
    # $entry =~ s/(<s lang=\"hil\">[A-Z][^<]*?[.!?]?<\/s>(?:, etc\.)?) ([A-Z][^<]*?[.!?])/<ex>\1 <s>\2<\/s><\/ex>/sg;

    ######### END EXPERIMENTAL

    print $entry;
}


sub handleTranslations {
    my $translations = shift;

    # translations, separated by commas or semicolons. Also keep other punctuation out of tagging.
    # To do so we split while also capturing the separators.

    my $result = '';
    my @phrases = split(/([.,;]\s+)/, $translations);
    foreach my $phrase (@phrases) {
        if ($phrase =~ /[a-záàâéèêíìîóòôúùûñ -]+/i and $phrase !~ /[ -]+/i) {
            my $before = $`;
            my $phrase = $&;
            my $after = $';
            $result .= "$before<tr>$phrase</tr>$after";
        } else {
            $result .= $phrase;
        }
    }

    return $result;
}
