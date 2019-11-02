# WCED-tag.pl -- add tagging to Wolff's Cebuano-English Dictionary (version 2, for formatted text)

use strict;

use CebuanoAffixes qw/combineAffix/;



my $infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");

$infile =~ /^([A-Za-z0-9-]*?)\.txt$/;
my $basename = $1;

$infile =~ /([1-9][0-9]+)\.txt$/;
my $entryid = 4000 * $1;


my %hashWords = ();

openFilesSql();
handleDictionary();

# print STDERR "\nNumber of entries: $entryid\n";


sub handleDictionary()
{
    print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
    print "<?xml-stylesheet type=\"text/xsl\" href=\"WCED-view.xsl\"?>\n";
    print "<!DOCTYPE dictionary [\n";
    print "    <!ENTITY mdash \"&#x2014;\">\n";
    print "    <!ENTITY apos \"&#x2019;\">\n";
    print "    <!ENTITY ldquo \"&#x201C;\">\n";
    print "    <!ENTITY rdquo \"&#x201D;\">\n";
    print "]>\n";
    print "<dictionary lang=\"en\">\n";

    while (<INPUTFILE>)
    {
        my $line = $_;

        # Start of new entry
        if ($line =~ /^<p>/)
        {
            my $remainder = $';
            chomp($remainder);
            handleEntry($remainder);
        }
    }

    print "</dictionary>\n";
    print STDERR "\n";
}




sub handleEntry($)
{
    my $entry = shift;

    # Patterns to recognize Cebuano fragments. (upper case, lower case, both cases, both cases plus punctuation)
    my $UC = "(?:[ABDGHIKLMNPRSTUVWY¡Õ⁄¿ÃŸ-]|(?:\\[v[AUI]\\])|(?:\\[=[¡Õ⁄¿ÃŸ]\\]))";
    my $LC = "(?:[abdghiklmnprstuvwy·Ì˙‡Ï˘-]|(?:\\[v[aui]\\])|(?:\\[=[·Ì˙‡Ï˘]\\]))";
    my $LT = "(?:[ABDGHIKLMNPRSTUVWY¡Õ⁄¿ÃŸabdghiklmnprstuvwy·Ì˙‡Ï˘-]|(?:\\[v[AUIaui]\\])|(?:\\[=[¡Õ⁄¿ÃŸ·Ì˙‡Ï˘]\\]))";
    my $LP = "(?:[ABDGHIKLMNPRSTUVWY¡Õ⁄¿ÃŸabdghiklmnprstuvwy·Ì˙‡Ï˘., ()-]|(?:\\[v[AUIaui]\\])|(?:\\[=[¡Õ⁄¿ÃŸ·Ì˙‡Ï˘]\\]))";

    # Handle (<-) and (->). (Allow for misreading parens and braces)
    #$entry =~ s/[{(]<-[)}]/(&lt;-)/sg;
    #$entry =~ s/[{(]->[)}]/(-&gt;)/sg;

    # Handle &
    $entry =~ s/\&/\&amp;/sg;

    $entry =~ s/[{(]<-[)}]/´/sg;
    $entry =~ s/[{(]->[)}]/ª/sg;



    # Remove SGML style comments
    $entry =~ s/<!--.*?-->//sg;

    # Eat extraneous spaces
    $entry =~ s/ +/ /sg;
    $entry =~ s/^ +//;
    $entry =~ s/ +$//;

    # Normalize punctuation around formatting tags (twice, to make them bubble out):
    # $entry =~ s/<\/(i|b|sc)>([.,:;?!])/\2<\/\1>/sg;
    $entry =~ s/([.,:;?!])<\/(i|b|sc)>/<\/\2>\1/sg;
    $entry =~ s/([.,:;?!])<\/(i|b|sc)>/<\/\2>\1/sg;


    ##### GRAMMAR #####

    # Recognize POS symbols
    $entry =~ s/<i>(a|n|v)<\/i>/<pos>\1<\/pos>/sg;

    # Tag the verb inflection types accordingly. (Note that we accept el for one here)
    $entry =~ s/(\[[ABCabcSNP1-9()]+(; ?[abcSNPl1-9()]+)?\])/<itype>\1<\/itype>/sg;

    # Tag the whole of pos and itype as a gramGrp
    $entry =~ s/(<pos>(a|n|v)<\/pos>(?: +<itype>[^>]+<\/itype>)?)/<gramGrp>\1<\/gramGrp>/sg;


    ##### MEANING #####

    # Recognize meaning numbers
    my $numberPattern = "(?:[1-9][0-9]*[a-z]?|[a-z])";
    $entry =~ s/<b>(${numberPattern}(, ${numberPattern})*)<\/b>/<number>\1<\/number>/sg;



    # Don't care about <corr>...</corr> tags for now
    $entry =~ s/<corr\b.*?>(.*?)<\/corr>/\1/sg;

    # Turn <pb> tags to XML style tags.
    $entry =~ s/<pb n=([0-9]+)>/<pb n=\"\1\"\/>/sg;
    # $entry =~ s/<pb n=([0-9]+)>/ /sg;

    # Recognize proofreader's notes
    $entry =~ s/\[\*\*(.*?)\]/<note>\1<\/note>/sg;


    # Recognize @-tagged translations
    $entry =~ s/[@]([A-Za-z-]+)/<tr>\1<\/tr>/sg;
    $entry =~ s/[@]{([^}]*)}/<tr>\1<\/tr>/sg;


    # Recognize cross references
    $entry =~ s/(see *|= *)?<sc>([^<]+)<\/sc>(, (?:<pos>[anv]<\/pos> ?)?(?:<number>[0-9]+[a-z]?<\/number>))?/<xref>\1<hw>\2<\/hw>\3<\/xref>/sg;




    # Clear-out pos and numbers within cross references.
    my $remainder = $entry;
    $entry = '';
    while ($remainder =~ /<xref>.*?<\/xref>/) 
    {
        $entry .= $`;
        my $xref = $&;
        $remainder = $';

        $xref =~ s/<\/?gramGrp>//sg;
        $xref =~ s/<pos>/<ix>/sg;
        $xref =~ s/<\/pos>/<\/ix>/sg;
        $xref =~ s/<number>/<bx>/sg;
        $xref =~ s/<\/number>/<\/bx>/sg;
        $entry .= $xref;
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

    $entry = tagForms($entry);


    # Recognize subscript numbers within forms
    $entry =~ s/\_\{?([0-9]+)\}?/<number>\1<\/number>/sg;


    # Try our luck at recognizing examples:
    $entry =~ s/<i>(${UC}[^<]+[,!?])<\/i> ([A-Z][^<]*?[.!?])/<eg><q>\1<\/q> <trans>\2<\/trans><\/eg>/sg;

    $entry =~ s/´/(&#8592;)/sg;
    $entry =~ s/ª/(&#8594;)/sg;


    # add outer tags

    $entry = "<entry>$entry</entry>";


    print "$entry\n\n";

    # handleEntrySql($hw, $entry);

}


sub tagForms($)
{
    my $remainder = shift;
    my $entry = "";

    my $currentForm = "";
    while ($remainder =~ /<form>([^>]+)<\/form>/) 
    {
        my $before = $`;
        my $match = $&;
        my $form = $1;
        $remainder = $';

        if ($entry eq "") 
        {
            $currentForm = cleanForm($form);
            $entry .= tagRoles($before) . "<sub form='$currentForm'>" . $match;
        }
        else
        {
            my $pattern = cleanForm($form);
            $entry .=  tagRoles($before) . "</sub>" . "<sub form='" . combineAffix($currentForm, $pattern) . "'>" . $match;
        }
    }
    if ($entry ne "") 
    {

        $entry .= tagRoles($remainder) . "</sub>";
    }
    else
    {
        $entry .= tagRoles($remainder);
    }

    return $entry;
}


sub cleanForm($)
{
    my $form = shift;

    $form =~ s/\_\{?[0-9]+\}?//sg;
    $form =~ s/\<number>[0-9]+<\/number>//sg;
    return $form;
}


sub tagRoles($)
{
    my $remainder = shift;
    my $entry = "";
    while ($remainder =~ /<gramGrp>(.*?)<\/gramGrp>/) 
    {
        my $before = $`;
        my $match = $&;
        my $role = $1;
        $remainder = $';

        if ($entry eq "") 
        {
            $entry .= tagSenses($before) . "<hom>" . $match;
        }
        else
        {
            $entry .=  tagSenses($before) . "</hom>" . "<hom>" . $match;
        }
    }
    if ($entry ne "") 
    {

        $entry .= tagSenses($remainder) . "</hom>";
    }
    else
    {
        $entry .= tagSenses($remainder);
    }

    return $entry;
}


sub tagSenses($)
{
    my $remainder = shift;
    my $entry = "";
    while ($remainder =~ /<number>([^>]+)<\/number>/) 
    {
        my $before = $`;
        my $match = $&;
        my $number = $1;
        $remainder = $';

        if ($entry eq "") 
        {
            $entry .= $before . "<sense n='$number'>" . $match;
        }
        else
        {
            $entry .=  $before . "</sense>" . "<sense n='$number'>" . $match;
        }
    }
    if ($entry ne "") 
    {
        $entry .= $remainder . "</sense>";
    }
    else
    {
        $entry .= $remainder;
    }

    return $entry;
}






####### SQL Stuff ###############################################

sub openFilesSql()
{
    open (WORDS,    ">$basename-headwords.sql") || die("Could not create output file 'headwords.sql'");
    open (ENTRIES,  ">$basename-entries.sql")   || die("Could not create output file 'entries.sql'");
}


sub handleEntrySql($$)
{
    my $headword = shift;
    my $entry = shift;

    if ($headword ne '')
    {
        $entryid++;
        my $normalized = normalizeWord($headword);

        print WORDS     'INSERT INTO ceb_word (word, entryid, type) VALUES (' . sqlQuote($normalized) . ", $entryid, 1);\n";
        print ENTRIES   "INSERT INTO ceb_entry (entryid, entry) VALUES ($entryid, " . sqlQuote($entry) . ");\n";

        addSearchWords($entryid, $entry);
    }
}


sub addSearchWords($$)
{
    my $entryid = shift;
    my $entry = shift;
    my $entry = normalizeWord($entry);

    $entry =~ s/<.*?>/ /g;          # drop XML tags
    $entry =~ s/[.,:;?!()]/ /g;     # drop punctuation
    $entry =~ s/\[|\]/ /g;          # drop brackets
    $entry =~ s/ +/ /g;             # drop redundant spaces

    my @words = split(/ /, $entry);     # split on spaces

    # Keep unique words only.
    %hashWords = map { $_ => 1 } @words;
    @words = sort { lc($a) cmp lc($b) } keys %hashWords;

    foreach my $word (@words)
    {
        if ($word =~ /^[a-z-][a-z0-9'-]+$/i  && $word ne '--')
        {
            print WORDS 'INSERT INTO ceb_word (word, entryid, type) VALUES (' . sqlQuote($word) . ", $entryid, 0);\n";
        }
    }
}


sub normalizeWord($)
{
    my $word = shift;

    # accented to unaccented:
    $word =~ tr/¡Õ⁄¿ÃŸ·Ì˙‡Ï˘/AIUAIUaiuaiu/;
    $word =~ s/\[[v=]([AUIaui])\]/\1/g;

    return lc $word;
}


sub sqlQuote($)
{
    my $string = shift;
    $string =~ s/\'/\'\'/g;
    return "'$string'";
}




