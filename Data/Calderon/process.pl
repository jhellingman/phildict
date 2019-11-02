# process.pl -- Process the Calderon EST dictionary.

while (<>) {
    my $line = $_;
    chop $line;

    if ($line =~ /^N: ([0-9]+)/) {
        my $n = $1;
        print  "<pb n=$n>\n";
    }

    if ($line =~ /^H: ([A-Z]+)/) {
        my $letter = $1;
        print  "<div1 id=letter$letter>\n<head>$letter</head>\n";
    }

    if ($line =~ /^C: (.*?)$/) {
        my $crossref = $1;
        print  "\n<p>$crossref\n";
    }

    if ($line =~ /^E: (.*?)$/) {
        my $english = $1;
        print  "\n<p><hi rend=bold>$english</hi>, ";
    }

    if ($line =~ /^G: (.*?)$/) {
        my $grammar = $1;
        if ($grammar ne "*") {
            print  "<hi>$grammar</hi> ";
        }
    }

    if ($line =~ /^P: (.*?)$/) {
        my $pronunciation = $1;
        if ($pronunciation ne "*") {
            print  "<foreign lang=und>[$pronunciation]</foreign>";
        }
    }

    if ($line =~ /^S: (.*?)$/) {
        my $spanish = $1;
        print  "\n<lb><foreign lang=es>$spanish</foreign>.";
    }

    if ($line =~ /^T: (.*?)$/) {
        my $tagalog = $1;
        print  "\n<lb><hi lang=tl>$tagalog</hi>\n";
    }
}

print "</body>\n";
print "<back id=backmatter>\n";
print "<divGen id=toc type=toc>\n";
print "<divGen type=Colophon>\n";
print "</back>\n";
print "</text>\n";
print "</TEI.2>\n";
