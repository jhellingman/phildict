
system("tei2html -u EspanolBisaya-1.0.tei");
system("perl -S ucwords.pl -r EspanolBisaya.xml > words-retro.html");
