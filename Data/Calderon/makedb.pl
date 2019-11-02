# makedb.pl -- Produce the database table for Calderon's dictionary.

use strict;

my $english = "";
my $grammar = "";
my $pronunciation = "";
my $spanish = "";
my $tagalog = "";


while (<>) {
    my $line = $_;
    chop $line;

    if ($line =~ /^E: (.*?)$/) {
        $english = transform($1);
    }

    if ($line =~ /^G: (.*?)$/) {
        $grammar = $1;
        if ($grammar eq "*") {
            $grammar = "";
        }
        $grammar = transform($grammar);
    }

    if ($line =~ /^P: (.*?)$/) {
        $pronunciation = transform($1);
    }

    if ($line =~ /^S: (.*?)$/) {
        $spanish = transform($1);
    }

    if ($line =~ /^T: (.*?)$/)
    {
        $tagalog = transform($1);

        # now we should have a complete entry:

        print "INSERT INTO calderon VALUES " .
            "($english, $grammar, $pronunciation, $spanish, $tagalog);\n";

        $english = "";
        $grammar = "";
        $pronunciation = "";
        $spanish = "";
        $tagalog = "";
    }
}


sub transform {
    my $s = shift;
    return quoteForSql(entities2ascii($s));
}


sub quoteForSql {
    my $s = shift;
    $s =~ s/\'/''/g;
    return "'$s'";
}


sub entities2ascii {
    my $s = shift;
    $s =~ s/\&apos;/'/g;
    $s =~ s/\&gtilde;/g/g;
    return $s;
}
