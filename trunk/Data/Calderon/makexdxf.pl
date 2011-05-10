# makexdxf.pl -- Produce the database table for Calderon's dictionary.



print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
print "<!DOCTYPE xdxf [\n";
print "    <!ENTITY mdash \"&#x2014;\">\n";
print "    <!ENTITY oelig \"&#339;\">\n";
print "    <!ENTITY frac12 \"&#189;\">\n";
print "    <!ENTITY ldquo \"&#x201C;\">\n";
print "    <!ENTITY rdquo \"&#x201D;\">\n";
print "]>\n";
print "<?xml-stylesheet type=\"text/xsl\" href=\"XDXF-draft-logical-05-to-html.xsl\"?>\n";

print "<xdxf lang_from=\"ENG\" lang_to=\"TGL\">\n";
print "<full_name lang_user=\"ENG\">English-Tagalog Dictionary</full_name>\n";
print "<description>Derived from Calderon's 1916 English-Spanish-Tagalog Dictionary</description>\n";



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
		print "<ar>\n" .
				"<head><k>$english</k></head>\n" .
				"<def>\n" .
					"<tr>$pronunciation</tr>\n" .
					"<pos>$grammar</pos>\n" .
					"<dtrn lang=\"es\">$spanish</dtrn>\n" .
					"<dtrn lang=\"tl\">$tagalog</dtrn>\n" .
				"</def>\n" .
			  "</ar>\n";

		$english = "";
		$grammar = "";
		$pronunciation = "";
		$spanish = "";
		$tagalog = "";
	}
}

print "</xdxf>\n";




sub entities2ascii
{
	my $s = shift;
	$s =~ s/\&apos;/'/g;
	$s =~ s/\&gtilde;/g/g;
	return $s;
}
