

system("perl identry.pl EspanolBisaya-0.1.tei > edeb-0.2.tei");
system("perl refvide.pl edeb-0.2.tei > edeb-0.3.tei");
system("tei2html -u edeb-0.3.tei");

system("perl -S ucwords.pl -r EspanolBisaya.xml > words-retro.html");

# system("tei2html -k --kwicvariants=3 edeb-0.3.tei");

# system("tei2html -k --kwicmixup=\"in m ni\" --kwicvariants=3 edeb-0.3.tei");
# system("tei2html -k --kwicmixup=\"u n\" --kwicvariants=3 edeb-0.3.tei");
# system("tei2html -k --kwicmixup=\"u o\" --kwicvariants=3 edeb-0.3.tei");
# system("tei2html -k --kwicmixup=\"c o\" --kwicvariants=3 edeb-0.3.tei");
# system("tei2html -k --kwicmixup=\"s c\" --kwicvariants=3 edeb-0.3.tei");
