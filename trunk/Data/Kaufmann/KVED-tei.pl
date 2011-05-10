# KVED-tei.pl -- add TEI tagging to Kaufmann's Visayan-English Dictionary

use strict;

my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");


handleDictionary();



sub handleDictionary()
{
    while (<INPUTFILE>)
    {
        my $line = $_;

        # Start of new entry
        while ($line =~ /^<p><b>(.*?)(,?)<\/b>/) 
        {
            my $entry = $line;

            # More lines in entry?
            while (<INPUTFILE>) 
            {
                $line = $_;

                if ($line eq "\n") 
                {
                    next;
                }

                # Old entry ends where new entry starts.
                if ($line =~ /^<p><b>(.*?)(,?)<\/b>/  || $line =~ /^<\/?div[0-9]/) 
                {
                    handleEntry($entry);
                    $entry = $line;
                    last;
                }

                # Close tag <p> of remaining lines:
                if ($line =~ /^<p>/) 
                {
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

    print STDERR "\n";
}



sub handleLine($)
{
    my $line = shift;
    print $line;
}


sub handleEntry($)
{
    my $entry = shift;

    print STDERR "|";

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

    # Convert double dollars to <s lang=es> tags
    $entry =~ s/\$\$(.*?)\$\$/<s lang=\"es\">\1<\/s>/sg;

    # Drop redundant dollars.
    $entry =~ s/\$ <pb n=([0-9]+)>\$/ <pb n=\1>/sg;     # around <pb tags>
    $entry =~ s/\$([.,:;()] )\$/\1/sg;                  # around spaces and punctuation

    # Convert single dollars to <s lang=hil> tags
    $entry =~ s/\$(.*?)\$/<s lang=\"hil\">\1<\/s>/sg;

    # Bring sentence-ending punctuation inside the <s> element.
    $entry =~ s/<\/s>([.!?])/\1<\/s>/sg;


    # Normal entry: <p><b>....,</b>  ->  <hw>....</hw>,
    if ($entry =~ /^<p><b>(.*?)(,?)<\/b>/s) 
    {
        my $headword = $1;
        my $comma = $2;
        my $tail = $';

        # $entry = "<entry>\n<hw>$headword</hw>$comma$tail</entry>\n";
    }

    # Cross references are tagged with ^...^
    $entry =~ s/\^(.*?)\^/<xref>\1<\/xref>/sg;

    print $entry;
    print "\n";
}
