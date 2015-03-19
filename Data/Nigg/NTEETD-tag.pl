# NTEETD-tag.pl -- add tagging to Nigg's 1904 Tagalog-English English-Tagalog Dictionary

use strict;

my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");

handleDictionary();

my $emptyline = 1;

sub handleDictionary()
{
    # print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
    # print "<dictionary lang=\"en\">\n";
    
    while (<INPUTFILE>)
    {
        my $line = $_;
        chomp($line);
        
        # print STDERR "[LINE: $line]\n";
        if ($emptyline == 1 && $line ne "")
        {
            $emptyline = 0;
            print "<p>";
        }
        if ($emptyline == 0 && $line eq "")
        {
            $emptyline = 1;
        }
        handleLine($line);
        print "\n";
    }

    # print "</dictionary>\n";

    print STDERR "\n";
}


sub handleLine($)
{
    my $line = shift;

    #### $line =~ s/-*File: 0*([0-9]+)\.png-*\\([^\\]+)\\([^\\]?)(\\([^\\]+))?(\\([^\\]+)\\)?.*$/<pb n=\1>/g;
    #### $line =~ s/<pb n=([0-9]+)>/<span class='pb'>[\1]<\/span>/g;

    $line =~ s/ +/ /g;
    $line =~ s/–/-/g;

    # drop italic tags for now
    #### $line =~ s/<\/?i\/?>//is;
    
    # tag head word and grammar indicators.
    $line =~ s/^(.*?)-(a|adv|n|prep|conj|pro|inter|v)\.?-/<b>\1<\/b> <i>\2<\/i> /is;
    $line =~ s/^(.*?)[ -](adv|n|prep|conj|pro|inter|v)\.?[ -]/<b>\1<\/b> <i>\2<\/i> /is;  # no a to limit false positives.
    $line =~ s/^([a-z]+)[ -](a|adv|n|prep|conj|pro|inter|v)\.?[ -]/<b>\1<\/b> <i>\2<\/i> /is;
    
    # Fix <corr></b> to </b><corr> case.
    $line =~ s/<corr(.*?)><\/b>/<\/b><corr\1>/sg;

    # Now we can replace the &#x2D; with hyphens and &#x20; with spaces.
    $line =~ s/[&][#]x2D;/-/sg;
    $line =~ s/[&][#]x20;/ /sg;

    # handle ~g and ñg (just drop for now)
    $line =~ s/\[~n\]/ñ/sg;
    $line =~ s/~n/ñ/sg;
    $line =~ s/\[~g\]/&gtilde;/sg;
    $line =~ s/~g/&gtilde;/sg;
    $line =~ s/ñg/n&gtilde;/sg;

    $line =~ s/\[~N\]/Ñ/sg;
    $line =~ s/~N/Ñ/sg;
    $line =~ s/\[~G\]/&Gtilde;/sg;
    $line =~ s/~G/&Gtilde;/sg;
    $line =~ s/ÑG/N&Gtilde;/sg;
    
    # Turn <pb> tags to XML style tags. 
    #### $line =~ s/<pb n=([0-9]+)>/<pb n=\"\1\"\/>/sg;
    
    # Convert proofer's comments to SGML comments
    #### $line =~ s/\[\*\*(.*?)\]/<!-- \1 -->/sg;

    # Normalize formatting tags.
    $line =~ s/<b>/<hi rend=bold>/sg;
    $line =~ s/<\/b>/<\/hi>/sg;
    $line =~ s/<sc>/<hi rend=sc>/sg;
    $line =~ s/<\/sc>/<\/hi>/sg;
    $line =~ s/<i>/<hi>/sg;
    $line =~ s/<\/i>/<\/hi>/sg;

    print $line;
}
