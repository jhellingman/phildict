@echo off

echo Process Calderon's Dictionary

perl process.pl < EST-content-1.0.txt > EST-content.tei

cat EST-Frontmatter-1.0.tei EST-content.tei > EST.tei

perl -S tei2html.pl -h -e EST.tei

