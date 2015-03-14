# WCED-tag.pl -- add tagging to Wolff's Cebuano-English Dictionary


$infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");

$infile =~ /^([A-Za-z0-9-]*?)\.txt$/;
my $basename = $1;

$infile =~ /([1-9][0-9]+)\.txt$/;
my $entryid = 4000 * $1;


openFilesSql();
handleDictionary();

# print STDERR "\nNumber of entries: $entryid\n";


sub handleDictionary()
{
    print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
    print "<!DOCTYPE dictionary [\n";
    print "    <!ENTITY mdash \"&#x2014;\">\n";
    print "    <!ENTITY apos \"&#x2019;\">\n";
    print "    <!ENTITY ldquo \"&#x201C;\">\n";
    print "    <!ENTITY rdquo \"&#x201D;\">\n";
    print "]>\n";
    print "<dictionary lang=\"en\">\n";

    while (<INPUTFILE>)
    {
        $line = $_;

        # Start of new entry
        if ($line =~ /^<p>/)
        {
            $remainder = $';
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

    # Remove SGML style comments
    $entry =~ s/<!--.*?-->//sg;

    # Eat extraneous spaces
    $entry =~ s/ +/ /sg;
    $entry =~ s/^ +//;
    $entry =~ s/ +$//;

    # Don't care about <corr>...</corr> tags for now
    $entry =~ s/<corr\b.*?>(.*?)<\/corr>/\1/sg;

    # Turn <pb> tags to XML style tags.
    $entry =~ s/<pb n=([0-9]+)>/<pb n=\"\1\"\/>/sg;

    # Handle (<-) and (->). (Allow for misreading parens and braces)
    $entry =~ s/[{(]<-[)}]/(&lt;-)/sg;
    $entry =~ s/[{(]->[)}]/(-&gt;)/sg;

    # Tag the verb inflection types accordingly. (Note that we accept el for one here)
    $entry =~ s/(\[[ABCabcSNP1-9()]+(; ?[abcSNPl1-9()]+)?\])/<itype>\1<\/itype>/sg;

    # recognize simple headwords
    if ($entry =~ /^((\*?${LC}+)(_\{?([1-9])\}?)?)*/)
    {
        $hw = $2;
        $hn = $4;
        $tail = $';

        $entry = "<form>$hw</form>";
        if ($hn ne "")
        {
            $entry .= "<number>$hn</number>";
        }
        $entry .= "$tail";
    }

    # recognize additional form after the headword
    if ($entry =~ /<\/form>, (${LC}+)(?:_([1-9]))?/)
    {
        $head = $`;
        $hw = $1;
        $hn = $2;
        $tail = $';

        $entry = "$head</form>, <form>$hw</form>";
        if ($hn ne "")
        {
            $entry .= "<number>$hn</number>";
        }
        $entry .= "$tail";
    }

    # recognize POS symbols
    $entry =~ s/<\/form> ([nva]) /<\/form> <pos>\1<\/pos> /sg;
    $entry =~ s/ ([nva]) <itype>/ <pos>\1<\/pos> <itype>/sg;
    $entry =~ s/ ([nv]) / <pos>\1<\/pos> /sg;

    # recognize cross references
    $entry =~ s/= (${UC}+)(_\{?[1-9]\}?)?/= <ref>\1\2<\/ref>/g;
    $entry =~ s/see (${UC}+)(_\{?[1-9]\}?)?/see <ref>\1\2<\/ref>/g;
    $entry =~ s/see also (${UC}+)(_\{?[1-9]\}?)?/see also <ref>\1\2<\/ref>/g;

    # recognize example sentences
    $entry =~ s/(${UC}${LP}+,) ([A-Z][A-Za-z, ()'-]+\.)/<eg><q>\1<\/q> <trans>\2<\/trans><\/eg>/g;
    $entry =~ s/(${UC}${LP}+\?) ([A-Z][A-Za-z, ()'-]+\?)/<eg><q>\1<\/q> <trans>\2<\/trans><\/eg>/g;
    $entry =~ s/(${UC}${LP}+!) ([A-Z][A-Za-z, ()'-]+!)/<eg><q>\1<\/q> <trans>\2<\/trans><\/eg>/g;

    # recognize proofreader's notes
    $entry =~ s/\[\*\*(.*?)\]/<note>\1<\/note>/sg;

    # add outer tags

    $entry = "<entry>$entry</entry>";

    print "$entry\n\n";

    handleEntrySql($hw, $entry);

}


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
