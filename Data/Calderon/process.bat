@echo off
echo Process Calderon's Dictionary

perl convert.pl < EST-content-1.0.txt > EST-content.tei
cat EST-Frontmatter-1.0.tei EST-content.tei > EST-1.0.tei
perl -S tei2html.pl -h -e -r --sql EST-1.0.tei
