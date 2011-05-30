# WCED-db.pl -- create database structure from WCED xml file.

use strict;

use XML::LibXML;
# use XML::LibXSLT;

require Encode;
use Unicode::Normalize;
use DBI;

# use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

my $prefix = "wced_";
my $pageNum = 0;
my $nextPageNum = 0;
my $entryId = 0;
my $wordId = 0;

my %wordHash = ();


main();


sub main()
{
    my $infile = $ARGV[0];

    open (ENTRY,        ">entry.sql")       || die ("Could not create output file 'entry.sql'");
    open (WORD,         ">word.sql")        || die ("Could not create output file 'word.sql'");
    open (WORDENTRY,    ">wordentry.sql")   || die ("Could not create output file 'wordentry.sql'");

	my $dom = XML::LibXML->load_xml(location => $infile);
	my @entries = $dom->findnodes("/dictionary/entry");

	foreach my $entry (@entries) 
	{
		handleEntry($entry);
	}
}


#
# handleEntry() -- print the SQL statment for an entry.
#
sub handleEntry($)
{
    my $entry = shift;

	my $entryId = $entry->find('@id')->to_literal;
	# print $entryId;

    print ENTRY "INSERT INTO `" . $prefix . "entry` VALUES ($entryId, " .
        quoteSql($entry->toString()) .
        ", " . $pageNum .
        ");\n";

	# Forms
	my @words = $entry->findnodes(".//w");
	my $firstWord = '';
	foreach my $word (@words) 
	{
		if ($firstWord eq '') 
		{
			$firstWord = $word->textContent;
			# print "\n\n" . $word->textContent . "\n";
		}
		else
		{
			# print $firstWord . " + " . $word->textContent . "\n";
		}
	}
}


#
# writeLanguageWords() -- write the collected words for a certain language to SQL statements.
#
sub writeLanguageWords($)
{
    my $lang = shift;
    my @wordList = keys %{$wordHash{$lang}};

    foreach my $word (@wordList)
    {
        if ($word ne "")
        {
            $wordId++;
            my $normalizedWord = "";
            if ($lang eq "ceb")
            {
                $normalizedWord = normalizeWolff($word);
            }

            print WORD "INSERT INTO `" . $prefix . "word` VALUES ($wordId, " .
                quoteSql($word) . ", " .
                quoteSql($normalizedWord) . ", " .
                quoteSql($lang) .
                ");\n";

            my @entries = split(/ /, $wordHash{$lang}{$word});
            foreach my $entryId (@entries)
            {
                if ($entryId ne "")
                {
                    print WORDENTRY "INSERT INTO `" . $prefix . "wordentry` VALUES ($wordId, $entryId);\n";
                }
            }
        }
    }
}



#
# handleHeadWords() -- collect the headwords in an entry
#
sub handleHeadWords($)
{
    my $entry = shift;
    my $remainder = $entry;
    while ($remainder =~ /<hw>(.*?)<\/hw>/)
    {
        my $phrase = $1;
        $remainder = $';

        while ($phrase =~ /<s lang=\"hil\">(.*?)<\/s>/)
        {
            my $word = $1;
            $phrase = $';

            $word = stripXmlTags($word);
            $word = stripPunctuation($word);

            my @words = split (/ /, $word);
            foreach my $word (@words)
            {
                handleWord($word, "HW", $entryId);
            }
        }
    }
}


#
# handleWords() -- collect all the words in an entry
#
sub handleWords($)
{
    my $entry = shift;

    my $remainder = $entry;
    while ($remainder =~ /<s lang=\"hil\">(.*?)<\/s>/)
    {
        my $before = $`;
        my $phrase = $1;
        $remainder = $';
        handleFragmentWords($before, "EN");
        handleFragmentWords($phrase, "CEB");
    }
    handleFragmentWords($remainder, "EN");
}


#
# handleFragmentWords() -- collect the words in a certain language in an entry
#
sub handleFragmentWords($$)
{
    my $phrase = shift;
    my $lang = shift;

    # drop tags from phrase
    $phrase =~s/<[a-z0-9.-]+\b(.*?)>/ /g;
    $phrase =~s/<\/[a-z0-9.-]+>/ /g;

    # drop punctuation from phrase
    $phrase =~s/\&mdash;/ /g;
    $phrase =~s/[".,:;?!() *[\]]+/ /g;
    $phrase =~s/--/ /g;

    # split into words
    my @words = split(/ /, $phrase);

    foreach my $word (@words)
    {
        handleWord($word, $lang, $entryId);
    }
}


#
# handleWord() -- store a single word in the hash with the entry ids it appears with.
#
sub handleWord($$$)
{
    my $word = shift;
    my $lang = shift;
    my $entryId = shift;

    $word = lc($word);

    if (index($wordHash{$lang}{$word}, " $entryId ") > 0)
    {
        # word already counted with this entry.
        return;
    }
    if (!defined($wordHash{$lang}{$word}) || $wordHash{$lang}{$word} eq "")
    {
        # word not seen before: start new entry.
        $wordHash{$lang}{$word} = " ";
    }

    $wordHash{$lang}{$word} .= "$entryId ";
}


#
# normalizeWolff() -- normalize the spelling of Cebuano words (as written by Wolff).
#
sub normalizeWolff($)
{
    my $word = shift;

    $word = lc($word);

    $word =~ s/[a·‡‚A¡¿¬]/a/g;
    $word =~ s/[eÈËÍE…» ÌÏÓIÕÃŒ]/i/g;
    $word =~ s/[oÛÚÙO”“‘˙˘˚U⁄Ÿ€]/u/g;
    $word =~ s/[Ò—]/n/g;
    $word =~ s/-//g;

    return $word;
}


#
# quoteSql() -- quote a string for inclusion into a SQL query.
#
sub quoteSql($)
{
    my $field = shift;
    $field =~ s/\"/\"\"/g;
    return "\"$field\"";
}


#
# stripXmlTags() -- strip XML tags from a string.
#
sub stripXmlTags($)
{
    my $string = shift;
    $string =~ s/<\/?[a-z]+(.*?)>//g;
    return $string;
}


#
# stripPunctuation() -- strip punctuation marks from a string.
#
sub stripPunctuation($)
{
    my $string = shift;
    $string =~ s/[.,;:()?!]/ /g;
    return $string;
}
