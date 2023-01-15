# EDEB-tag.pl -- add tagging to Encarnacion: Diccionario Espa�ol-Bisaya

use strict;

my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");
open (XML,    ">output.xml") || die("Could not create output file 'output.xml'");


handleDictionary();


sub handleDictionary() {
    print XML "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
    print XML "<dictionary lang=\"es\">\n";
    
    my $entry = '';
    while (<INPUTFILE>) {
        my $line = $_;
        chomp($line);
        
        if ($line =~ /-----File: /) {
            # Forget this line
        } elsif ($line eq '' && $entry ne '') {
            handleEntry($entry);
            $entry = '';
        } elsif ($line ne '') {
            $entry .= ' ' . $line;
        }
    }

    if ($entry ne '') {
        handleEntry($entry);
    }

    print XML "</dictionary>\n";
    print STDERR "\n";
}


sub handleEntry($) {
    my $entry = shift;

    print XML "<entry>\n";

    # $entry =~ s/-*File: 0*([0-9]+)\.png-*\\([^\\]+)\\([^\\]?)(\\([^\\]+))?(\\([^\\]+)\\)?.*$/<pb n=\1>/g;
    # $entry =~ s/<pb n=([0-9]+)>/<span class='pb'>[\1]<\/span>/g;

    $entry =~ s/ +/ /g;
    $entry =~ s/^ //g;
    $entry =~ s/ $//g;

    # Remove italic and small-caps tags
    $entry =~ s/<\/?i\/?>//gis;
    $entry =~ s/<\/?sc\/?>//gis;

    # handle <, >, and &c.
    $entry =~ s/</&lt;/gis;
    $entry =~ s/>/&gt;/gis;
    $entry =~ s/\&c\b/&amp;c/gis;

    # Remove proofer's comments
    $entry =~ s/\[\*\*(.*?)\]//sg;

    # handle ~g and �g (just drop for now)
    $entry =~ s/\[~n\]/�/sg;
    $entry =~ s/~n/�/sg;
    $entry =~ s/\[~g\]/&gtilde;/sg;
    $entry =~ s/~g/&gtilde;/sg;
    $entry =~ s/�g/n&gtilde;/sg;
    # $entry =~ s/\[~g\]/g/sg;
    # $entry =~ s/~g/g/sg;
    # $entry =~ s/�g/ng/sg;

    $entry =~ s/\[~N\]/�/sg;
    $entry =~ s/~N/�/sg;
    $entry =~ s/\[~G\]/&Gtilde;/sg;
    $entry =~ s/~G/&Gtilde;/sg;
    $entry =~ s/�G/N&Gtilde;/sg;
    $entry =~ s/�g/N&gtilde;/sg;
    # $entry =~ s/\[~G\]/G/sg;
    # $entry =~ s/~G/G/sg;
    # $entry =~ s/�G/NG/sg;
    # $entry =~ s/�g/Ng/sg;


    my $remainder = $entry;
    my $newEntry = '';
    while ($remainder =~ / \* /) {
        my $part = $`;
        $remainder = $';

        if ($newEntry ne '') {
            $newEntry .= ' * '
        }
        $newEntry .= handlePart($part);
    }
    if ($newEntry ne '') {
        $newEntry .= ' * '
    }
    $newEntry .= handlePart($remainder);
    $entry = $newEntry;

    # Turn <pb> tags to XML style tags. 
    $entry =~ s/<pb n=([0-9]+)>/<pb n=\"\1\"\/>/sg;

    # Convert proofer's comments to SGML comments
    $entry =~ s/\[\*\*(.*?)\]/<!-- \1 -->/sg;

    print '<p>' . $entry . "\n\n";

    print XML "</entry>\n";
}


sub handlePart($) {
    my $part = shift;
    my $result = '';

    print XML "<part>\n";
    if ($part =~ /([^=]*?) ?(?:= ?)?V\. ?(.*)$/) {
        my $word = $1;
        my $xref = $2;
        if ($word eq '') {
            print XML "<xref>$xref</xref>\n";
            $result = "V. <i>$xref</i>";
        } else {
            print XML "<hw>$word</hw>\n";
            print XML "<xref>$xref</xref>\n";
            $result =  "<b>$word</b> V. <i>$xref</i>";
        }
    } elsif ($part =~ /([^=]*?) ?= ?(.*)$/) {
        my $word = $1;
        my $trans = translateCebuano($2);
        print XML "<hw>$word</hw>\n";
        print XML "<trans lang=\"ceb\">$trans</trans>\n";
        $result = "<b>$word</b> = $trans";
    } else {
        my $trans = translateCebuano($part);
        $result = $trans;
        print XML "<trans lang=\"ceb\">$trans</trans>\n";
    }
    print XML "</part>\n";
    return $result;
}


sub translateCebuano($)
{
    my $phrase = shift;

    return $phrase;

    $phrase =~ s/[���]/a/g;
    $phrase =~ s/[���]/e/g;
    $phrase =~ s/[���]/i/g;
    $phrase =~ s/[���]/o/g;
    $phrase =~ s/[���]/u/g;
    $phrase =~ s/\&gtilde;/g/g;

    $phrase =~ s/[���]/A/g;
    $phrase =~ s/[���]/E/g;
    $phrase =~ s/[���]/I/g;
    $phrase =~ s/[���]/O/g;
    $phrase =~ s/[���]/U/g;
    $phrase =~ s/\&Gtilde;/G/g;


    $phrase =~ s/\&c\b/&amp;c/g;




    $phrase =~ s/gui/gi/g;

    $phrase =~ s/qui/ki/g;
    $phrase =~ s/qu�/k�/g;
    $phrase =~ s/que/ke/g;
    $phrase =~ s/qu�/k�/g;
    
    $phrase =~ s/ci/si/g;
    $phrase =~ s/ce/se/g;
    $phrase =~ s/c/k/g;
    $phrase =~ s/j/h/g;
    $phrase =~ s/v/b/g;
    $phrase =~ s/z/s/g;
    $phrase =~ s/�/ny/g;
    
    
    $phrase =~ s/oa/wa/g;
    $phrase =~ s/ao/aw/g;


    $phrase =~ s/Gui/Gi/g;
    $phrase =~ s/Qui/Ki/g;
    $phrase =~ s/Qu�/K�/g;
    $phrase =~ s/Que/Ke/g;
    $phrase =~ s/Qu�/K�/g;
    $phrase =~ s/Ci/Si/g;
    $phrase =~ s/Ce/Se/g;
    $phrase =~ s/C/K/g;
    $phrase =~ s/Oa/Wa/g;
    $phrase =~ s/Ao/Aw/g;
    $phrase =~ s/J/H/g;
    $phrase =~ s/V/B/g;
    $phrase =~ s/Z/S/g;
    $phrase =~ s/�/Ny/g;


    return $phrase;
}