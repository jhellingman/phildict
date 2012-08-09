
echo Process Calderon's Dictionary

perl process.pl < EST-content-1.0.txt > EST-content.tei

cat EST-Frontmatter-1.0.tei EST-content2.tei > EST.tei

perl -S tei2html.pl EST.tei

