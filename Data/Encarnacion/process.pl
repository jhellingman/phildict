
system("tei2html -u EspanolBisaya-0.4.tei");
system("perl -S ucwords.pl -r EspanolBisaya.xml > words-retro.html");
