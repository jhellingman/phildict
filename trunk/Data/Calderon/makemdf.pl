# makemdf.pl -- Produce the database table for Calderon's dictionary.

$english = "";
$grammar = "";
$pronunciation = "";
$spanish = "";
$tagalog = "";

while (<>) 
{
	$line = $_;
	chop $line;


	if ($line =~ /^E: (.*?)$/)
	{
		$english = entities2ascii($1);
	}

	if ($line =~ /^G: (.*?)$/)
	{
		$grammar = $1;
		if ($grammar eq "*") 
		{
			$grammar = "";
		}
		$grammar = entities2ascii($grammar);
	}

	if ($line =~ /^P: (.*?)$/)
	{
		$pronunciation = entities2ascii($1);
	}

	if ($line =~ /^S: (.*?)$/)
	{
		$spanish = entities2ascii($1);
	}

	if ($line =~ /^T: (.*?)$/)
	{
		$tagalog = entities2ascii($1);
	
		# now we should have a complete entry:
		print 
			"\n" .
			"\\lx $english\n" .
			"\\ph $pronunciation\n" .
			"\\ps $grammar\n" .
			"\\gn $spanish\n" .
			"\\gr $tagalog\n";

		$english = "";
		$grammar = "";
		$pronunciation = "";
		$spanish = "";
		$tagalog = "";
	}
}




sub entities2ascii
{
	my $s = shift;
	$s =~ s/\&apos;/'/g;
	$s =~ s/\&gtilde;/g/g;
	return $s;
}
