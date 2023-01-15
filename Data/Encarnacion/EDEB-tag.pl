# EDEB-tag.pl -- add tagging to Encarnacion: Diccionario Español-Bisaya

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

    # handle ~g and ñg (just drop for now)
    $entry =~ s/\[~n\]/ñ/sg;
    $entry =~ s/~n/ñ/sg;
    $entry =~ s/\[~g\]/&gtilde;/sg;
    $entry =~ s/~g/&gtilde;/sg;
    $entry =~ s/ñg/n&gtilde;/sg;
    # $entry =~ s/\[~g\]/g/sg;
    # $entry =~ s/~g/g/sg;
    # $entry =~ s/ñg/ng/sg;

    $entry =~ s/\[~N\]/Ñ/sg;
    $entry =~ s/~N/Ñ/sg;
    $entry =~ s/\[~G\]/&Gtilde;/sg;
    $entry =~ s/~G/&Gtilde;/sg;
    $entry =~ s/ÑG/N&Gtilde;/sg;
    $entry =~ s/Ñg/N&gtilde;/sg;
    # $entry =~ s/\[~G\]/G/sg;
    # $entry =~ s/~G/G/sg;
    # $entry =~ s/ÑG/NG/sg;
    # $entry =~ s/Ñg/Ng/sg;


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

    $phrase =~ s/[áàâ]/a/g;
    $phrase =~ s/[éèê]/e/g;
    $phrase =~ s/[íìî]/i/g;
    $phrase =~ s/[óòô]/o/g;
    $phrase =~ s/[úùû]/u/g;
    $phrase =~ s/\&gtilde;/g/g;

    $phrase =~ s/[ÁÀÂ]/A/g;
    $phrase =~ s/[ÉÈÊ]/E/g;
    $phrase =~ s/[ÍÌÎ]/I/g;
    $phrase =~ s/[ÓÒÔ]/O/g;
    $phrase =~ s/[ÚÙÛ]/U/g;
    $phrase =~ s/\&Gtilde;/G/g;


    $phrase =~ s/\&c\b/&amp;c/g;




    $phrase =~ s/gui/gi/g;

    $phrase =~ s/qui/ki/g;
    $phrase =~ s/quí/kí/g;
    $phrase =~ s/que/ke/g;
    $phrase =~ s/qué/ké/g;
    
    $phrase =~ s/ci/si/g;
    $phrase =~ s/ce/se/g;
    $phrase =~ s/c/k/g;
    $phrase =~ s/j/h/g;
    $phrase =~ s/v/b/g;
    $phrase =~ s/z/s/g;
    $phrase =~ s/ñ/ny/g;
    
    
    $phrase =~ s/oa/wa/g;
    $phrase =~ s/ao/aw/g;


    $phrase =~ s/Gui/Gi/g;
    $phrase =~ s/Qui/Ki/g;
    $phrase =~ s/Quí/Kí/g;
    $phrase =~ s/Que/Ke/g;
    $phrase =~ s/Qué/Ké/g;
    $phrase =~ s/Ci/Si/g;
    $phrase =~ s/Ce/Se/g;
    $phrase =~ s/C/K/g;
    $phrase =~ s/Oa/Wa/g;
    $phrase =~ s/Ao/Aw/g;
    $phrase =~ s/J/H/g;
    $phrase =~ s/V/B/g;
    $phrase =~ s/Z/S/g;
    $phrase =~ s/Ñ/Ny/g;


    return $phrase;
}