# toEntities.pl -- change unicode characters to numeric entities.

use strict;
use utf8;
use open ':utf8';

my $inputFile   = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

while (<INPUTFILE>)
{
    my $line = $_;
    $line =~ s/([\x{0080}-\x{ffff}])/toEntity("$1")/ge;
    print $line;
}

sub toEntity($)
{
    my $char = shift;
    return "&#" . ord($char) . ";";
}
