# pgclean.pl

use strict;
use SgmlSupport qw/pgdp2sgml/;


my $file = $ARGV[0];
my $useExtensions = 0;

if ($file eq "-x")
{
    $useExtensions = 1;
    $file = $ARGV[1];
    print STDERR "USING EXTENSIONS FOR FRANCK!\n";
}


open(INPUTFILE, $file) || die("Could not open input file $file");


while (<INPUTFILE>)
{
    # Replace ampersands (if they are not likely entities):
    $_ =~ s/\& /\&amp; /g;
    $_ =~ s/\&$/\&amp;/g;
    $_ =~ s/\&c\. /\&amp;c. /g;

    # Replace PGDP page-separators (preserving proofers):
    # $_ =~ s/^-*File: 0*([0-9]+)\.png-*\\([^\\]+)\\([^\\]+)\\([^\\]+)\\([^\\]+)\\.*$/<pb n=\1 resp="\2|\3|\4|\5">/g;
    $_ =~ s/^-*File: 0*([0-9]+)\.(png|jpg)-*\\([^\\]+)\\([^\\]?)\\([^\\]+)\\([^\\]+)\\.*$//g;
    # For DP-EU:
    $_ =~ s/^-*File: 0*([0-9]+)\.(png|jpg)-*\\([^\\]+)\\([^\\]+)\\.*$//g;
    # For omitted proofer names.
    $_ =~ s/^-*File: 0*([0-9]+)\.(png|jpg)-*$//g;

    # Replace italics tag
    $_ =~ s/<i>//g;
    $_ =~ s/<\/i>//g;

    $_ =~ s/<b>//g;
    $_ =~ s/<\/b>//g;

    $_ =~ s/<sc>//g;
    $_ =~ s/<\/sc>//g;

    $_ =~ s/[\@{}]//g;

    # Replace special accented letters
    # $_ =~ s/\[=([aieouAIEOU])\]/\&\1macr;/g;
    $_ = pgdp2sgml($_, $useExtensions);

    $_ =~ s/[ \t]+/ /g;

    print;
}
