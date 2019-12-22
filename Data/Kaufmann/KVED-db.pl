# KVED-db.pl -- create database structure from KVED xml file.

use strict;

my $prefix = "kved_";
my $pageNum = 0;
my $nextPageNum = 0;
my $entryId = 0;
my $wordId = 0;
my $headId = 0;
my $word2Id = 0;

my %wordHash = ();

use SgmlSupport qw/sgml2utf/;

binmode(STDOUT, ":utf8");
use open OUT => ':utf8';

main();


sub main() {
    my $infile = $ARGV[0];

    open (INPUTFILE, $infile) || die("Could not open input file $infile");

    open (ENTRY,        ">SQL/kved_entry.sql")       || die ("Could not create output file 'SQL/kved_entry.sql'");
    open (WORD,         ">SQL/kved_word.sql")        || die ("Could not create output file 'SQL/kved_word.sql'");
    open (WORDENTRY,    ">SQL/kved_wordentry.sql")   || die ("Could not create output file 'SQL/kved_wordentry.sql'");

    open (SQLITE,       ">SQL/kved_sqlite.sql")      || die ("Could not create output file 'SQL/kved_sqlite.sql'");

    print SQLITE "\n\nBEGIN TRANSACTION;\n\n";

    while (<INPUTFILE>) {
        my $line = $_;
        if ($line =~ /<pb n=\"([0-9]+)\"\/>/) {
            $nextPageNum = $1;
        }

        if ($line =~ /<entry\b(.*?)>/) {
            handleEntry();
        }

        $pageNum = $nextPageNum;
    }

    # write collected words to SQL.
    writeLanguageWords("HW");
    writeLanguageWords("EN");
    writeLanguageWords("HIL");

    print SQLITE "\n\nCOMMIT;\n\n";
}


#
# Write the collected words for a certain language to SQL statements.
#
sub writeLanguageWords {
    my $lang = shift;
    my @wordList = keys %{$wordHash{$lang}};

    foreach my $word (@wordList) {
        if ($word ne "") {
            $wordId++;
            my $normalizedWord = "";
            if ($lang eq "HIL" || $lang eq "HW") {
                $normalizedWord = normalizeHiligaynon($word);
            }

            print WORD "INSERT INTO `" . $prefix . "word` VALUES ($wordId, " .
                quoteSql($word) . ", " .
                quoteSql($normalizedWord) . ", " .
                quoteSql($lang) .
                ");\n";

            my @entries = split(/ /, $wordHash{$lang}{$word});
            foreach my $entryId (@entries) {
                if ($entryId ne "") {
                    print WORDENTRY "INSERT INTO `" . $prefix . "wordentry` VALUES ($wordId, $entryId);\n";

                    # Write inserts for the SQL-lite structure to be used in App.
                    $word2Id++;
                    if ($lang eq "HW") {
                        $headId++;
                        my $type = "m";         # Always main entry.
                        my $pos = 0;            # Always at start of entry.
                        print SQLITE "INSERT INTO `" . $prefix . "head` VALUES($headId, " . quoteSql($word) . ", " . quoteSql($normalizedWord) . ", $entryId, " . quoteSql($type) . ", $pos);\n";
                    }

                    my $flags = $lang eq "HW" ? 1 : 4;
                    $lang = $lang eq "HW" ? "HIL" : $lang;
                    print SQLITE "INSERT INTO `" . $prefix . "word` VALUES($word2Id, $entryId, $flags, " . quoteSql($word) . ", " . quoteSql($lang) . ");\n";
                    if ($normalizedWord ne "" && $normalizedWord ne $word) {
                        $flags += 16;
                        $word2Id++;
                        print SQLITE "INSERT INTO `" . $prefix . "word` VALUES($word2Id, $entryId, $flags, " . quoteSql($normalizedWord) . ", " . quoteSql($lang) . ");\n";
                    }
                }
            }
        }
    }
}


#
# Print the SQL statment for an entry.
#
sub handleEntry {
    my $entry = "";

    while (<INPUTFILE>) {
        my $line = $_;
        if ($line =~ /<pb n=\"([0-9]+)\"\/>/) {
            $nextPageNum = $1;
        }
        if ($line =~ /<\/entry>/) {
            last;
        }
        $entry .= $line;
    }

    chomp $entry;

    $entry = sgml2utf($entry);

    $entryId++;
    print ENTRY "INSERT INTO `" . $prefix . "entry` VALUES ($entryId, " .
        quoteSql("<entry>$entry</entry>") .
        ", " . $pageNum .
        ");\n";

    # Write insert for the SQL-lite structure to be used in App.
    # First retrieve head words (between <hw> and </hw>

    $entry =~ /<hw>(.*?)<\/hw>/;
    my $head = $1;

    $head =~ s/<s lang=\"hil\">//g;
    $head =~ s/<\/s>//g;

    print SQLITE "INSERT INTO `" . $prefix . "entry` VALUES ($entryId, " .
        quoteSql($head) .
        ", " . quoteSql("<entry>$entry</entry>") .
        ", " . $pageNum .
        ");\n";

    handleHeadWords($entry);
    handleWords($entry);
}


#
# Collect the headwords in an entry
#
sub handleHeadWords {
    my $entry = shift;
    my $remainder = $entry;
    while ($remainder =~ /<hw>(.*?)<\/hw>/) {
        my $phrase = $1;
        $remainder = $';

        while ($phrase =~ /<s lang=\"hil\">(.*?)<\/s>/) {
            my $word = $1;
            $phrase = $';

            $word = stripXmlTags($word);
            $word = stripPunctuation($word);

            my @words = split (/ /, $word);
            foreach my $word (@words) {
                handleWord($word, 'HW', $entryId);
            }
        }
    }
}


#
# Collect all the words in an entry
#
sub handleWords {
    my $entry = shift;

    my $remainder = $entry;
    while ($remainder =~ /<s lang=\"hil\">(.*?)<\/s>/) {
        my $before = $`;
        my $phrase = $1;
        $remainder = $';
        handleFragmentWords($before, 'EN');
        handleFragmentWords($phrase, 'HIL');
    }
    handleFragmentWords($remainder, 'EN');
}


#
# Collect the words in a certain language in an entry
#
sub handleFragmentWords {
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

    foreach my $word (@words) {
        handleWord($word, $lang, $entryId);
    }
}


#
# Store a single word in the hash with the entry ids it appears with.
#
sub handleWord {
    my $word = shift;
    my $lang = shift;
    my $entryId = shift;

    $word = lc($word);

    if ($word ne '' && $word ne "\n") {
        if (index($wordHash{$lang}{$word}, " $entryId ") > 0) {
            # word already counted with this entry.
            return;
        }
        if (!defined($wordHash{$lang}{$word}) || $wordHash{$lang}{$word} eq '') {
            # word not seen before: start new entry.
            $wordHash{$lang}{$word} = ' ';
        }
        $wordHash{$lang}{$word} .= "$entryId ";
    }
}


#
# Normalize the spelling of Hiligaynon words.
#
sub normalizeHiligaynon {
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
# Quote a string for inclusion into a SQL query.
#
sub quoteSql {
    my $field = shift;
    $field =~ s/\"/\"\"/g;
    return "\"$field\"";
}


#
# Strip XML tags from a string.
#
sub stripXmlTags {
    my $string = shift;
    $string =~ s/<\/?[a-z]+(.*?)>//g;
    return $string;
}


#
# Strip punctuation marks from a string.
#
sub stripPunctuation {
    my $string = shift;
    $string =~ s/[.,;:()?!]/ /g;
    return $string;
}
