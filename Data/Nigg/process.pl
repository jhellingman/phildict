

# Preprocess the body files.
system ("perl NTEETD-tag.pl body-EN-TL-0.1.tei > body-EN-TL.tei");
system ("perl NTEETD-tag.pl body-TL-EN-0.1.tei > body-TL-EN.tei");
system ("perl NTEETD-tag.pl body-names-0.1.tei > body-names.tei");

# Combine them into the body
system ("perl include.pl front-matter-0.1.tei > TagalogDictionary.tei");

# Process the resulting file
system ("perl -S tei2html.pl TagalogDictionary.tei");


