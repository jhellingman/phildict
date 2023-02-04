
system("tei2html -u EspanolBisaya-0.6.tei");
system("perl -S ucwords.pl -r EspanolBisaya.xml > words-retro.html");
