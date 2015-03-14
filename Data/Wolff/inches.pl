# inches.pl -- change U.S. units to metric units

use strict;

my $inputFile   = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

while (<INPUTFILE>)
{
    my $remainder = $_;
    my $result = "";
    while ($remainder =~ /([0-9]+)(&frac([0-9])([0-9]);)?(&[Pp]rime;)/) 
    {
        $result .= $`;
        $remainder = $';

        my $match = $&;
        my $amount = $1;
        my $fraction = $2;
        my $numerator = $3;
        my $denominator = $4;
        my $unit = $5;

        if ($fraction ne "") 
        {
            $amount += $numerator / $denominator;
        }

        if ($unit eq "&Prime;") 
        {
            $result .= measureTag($match, roundMetric($amount * 25.6));
        }
        elsif ($unit eq "&prime;") 
        {
            $result .= measureTag($match, roundMetric($amount * 304.8));
        }
    }
    $result .= $remainder;

    print $result;
}

sub measureTag()
{
    my $original = shift;
    my $regular = shift;

    return "<measure reg=\"$regular\">$original</measure>";
}

sub roundMetric()
{
    my $mm = shift;

    if ($mm < 10) 
    {
        return sprintf("%.1f mm", $mm);
    }
    elsif ($mm < 100)
    { 
        return sprintf("%.1f cm", $mm / 10);
    }
    elsif ($mm < 1000) 
    {
        return sprintf("%.0f cm", $mm / 10);
    }
    elsif ($mm < 10000) 
    {
        return sprintf("%.1f m", $mm / 1000);
    }
    return sprintf("%.0f m", $mm / 1000);
}
