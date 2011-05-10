
echo Process Calderon's Dictionary

perl process.pl < EST-content-1.0.txt > EST-content.tei

patc -p ..\..\..\..\Tools\tei2html\tools\win2sgml.pat EST-content.tei  EST-content2.tei

cat EST-Frontmatter-1.0.tei EST-content2.tei > EST.tei

perl -S tei2xml.pl EST.tei

