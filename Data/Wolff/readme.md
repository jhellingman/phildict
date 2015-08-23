# Data for John U. Wolff's Dictionary of Cebuano-Visayan 

Description of files:

 * custom.css.xml: CSS to be included in the HTML version of the dictionary.
 * inches.pl: Perl script to add metric equivalents to measurements indicated in foot and inches.
 * process.pl: Perl scrpt to process the files. This will generate various derived files.
 * runsaxon.pl: Perl script to run Saxon from the command-line.
 * toEntities.pl: Perl script to convert non-ASCII characters to XML character entities.
 * WCED-A.tei .. WCED-Y.tei: master TEI file for the indicated letters.
 * WCED-addenda.tei: master file for the material in the addenda.
 * WCED-abbr.pl: Perl script to convert abbrevations (using {..|..} form) in the dictionary to tags.
 * WCED-collect.xsl: XSLT galley file that collects all entries together into a single output file. This version only includes the entry, and is suitable for preparing a database version for the website or app.
 * WCED-complete.xsl: XSLT galley file that collects all files together into a single output file. This version includes the preliminary matter, and is suitable for preparing a print or html edition.
 * WCED-db.xsl: XSLT file that converts the dictionary data to SQL statements (includes table structure).
 * WCED-downtag.pl: Perl script will replace several types of TEI tags with HTML tags.
 * WCED-downtag.xsl: XSLT file with the same function as WCED-downtag.pl.
 * WCED-frontmatter-0.1.tei: TEI file with the front-matter of the dictionary.
 * WCED-Prince.css: CSS file with style definitions to be used when generating PDF output with Prince XML.
 * WCED-samples.tei: TEI file used while developing and testing the conversion software.
 * WCED-support.tei: XSLT file with a few commonly used utility functions.
 * WCED-text.pl: Perl script to convert the XML to a plain-vanilla Unicode text file.
 * WCED-uptag1.pl: Perl script to add specific tags to the raw data. (Round 1).
 * WCED-uptag2.xsl: XSLT file to add implied structural information to the raw data. (Round 2).
 * WCED-uptag3.xsl: XSLT file to improve added structural information. (Round 3).
 * WCED-view.xsl: XSLT file to present to added structural information in HTML.


## Prerequisites.

To build the output versions of the dictionary, download and install my tei2html scripts.

Then run `process.pl`.

This will first process the individual letters, and then combine the data to produce the 
various outputs.

