

system("perl identry.pl EspanolBisaya-0.1.tei > edeb-0.2.tei");
system("perl refvide.pl edeb-0.2.tei > edeb-0.3.tei");
system("tei2html edeb-0.3.tei");

