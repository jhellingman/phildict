#summary User-Interface Design Considerations.

= Introduction =

The dictionary data here is collected to build an interactive web-dictionary. This dictionary website should be intuitive and easy to use for lay users, and also offer some advanced features to users with more complex queries.

Two interfaces will be produced

  * A full-blown website for large screen browsers.
  * An optimized mobile site for small screen browsers.

The optimized site will "borrow" some design elements from the [http://m.gutenberg.org/ebooks/?format=mobile Project Gutenberg mobile site].

= Basic Design =

== Search Interface ==

Based on some experimentation with various web-interfaces to dictionaries, the simplest possible interface will be used. This means, a single text-input box, with no further options. A separate search page will be used for each dictionary. (A meta-dictionary will be made available to search all dictionaries at once)

When the end user enters a query, the web application will behave as follows: (Assuming we use Wolff's Cebuano-English dictionary in the examples.)

  # Normalize the word according to rules for each of the covered languages of the dictionary. (e.g. 'maglutò' will be normalized to 'maglutu' in Cebuano; it would be normalized to magluto for the English query, but that will not result in a match in the English data.) 
  # Search for the query word in the entry headwords (using the normalized version specific to the language of the text).
  # Search for the query word in the list of morphological derived head-words (e.g., I query for 'maglutu' will find the entry 'lútù')
  # Search for the query word in the translated equivalents (tagged as such in the data; e.g. a search for the English word cook will find entries where 'cook' is offered as a translation for the Cebuano entry 'lútù')
  # Search for the query word in the full text. This will result in all entries that use the query word in their examples, providing an ample source of sample sentences to the user.

The results will be presented in groups, based on each search, sorted in alphabetical order of the head-word, and with duplicates removed.

The found matches will be highlighted in a specific color. The colors used will be indicated.

When multiple words are entered at once, the search is repeated for each word (OR-relationship).

When more than 20 entries are returned, paging will be used to limit the size of the resulting page.

When an entry is returned that contains just a cross reference, the referenced entry will be included directly after this entry (with a visual indication of this fact).

Other cross references will be presented as hyperlinks to entry referred to.

== Display Options ==

The data can be presented in several ways:

  # _Compact_: reflecting the traditional dictionary typography. Default in mobile application (appropriate for small screen sizes).
  # _Structural_: reflecting the logical structure of the entry, with abbreviations expanded. (appropriate for larger screen sizes).

In addition, templates can be used to present information on derived word forms.

== Advanced Search Features ==

Advanced features can be used by giving using a specialized query language in the one search box, e.g.

|| *Pattern* || *Meaning* ||
|| `word`  || Include results that have word; by default some degree of language-dependent normalization will be applied to the word. ||
|| `wo?d`  || Single letter wild-card. ||
|| `wo*d`  || zero or more letter wild-card. ||
|| `=word` || Only find exact matches (disable matching of derived words) ||
|| `==word` || Only find really exact matches (disable orthographic normalization) ||
|| `~word` || Allow fuzzy matching (interpretation of fuzziness depends on language) ||
|| `-word` || Exclude results that have word ||
|| `+word` || Only include entries with this word (that is, change default OR to AND, e.g., for a query for entries that contain both 'you' and 'me', enter `+you +me`) ||
|| `pos:n` || Only find nouns (i.e., having the `pos` element noun for one or more of their meanings.) ||
|| `lang:ceb` || Only find Cebuano words. ||
|| `ex:word` || Only find words as used in example sentences. ||

The meaning of the 'fuzziness' operators (`=`, `==`, `~`, `~~`) depends on the language being queried. The default will ignore minor orthographic changes (such as accents or American versus British spellings in English), adding `=` will make the match more strict, while adding `~` will make the match more fuzzy (Such as using soundex or metaphone algorithms).

All query words with the `+` operator will be joined together with an `AND`, and should appear within the returned entry. All query words without them will be joined with an `OR`, e.g.:

|| *Query*  || *Corresponding logic combination* ||
|| `w1`  || `'w1'`     ||
|| `w1 w2` || `'w1' OR 'w2'` ||
|| `w1 +w2` || `'w1' AND 'w2'` ||
|| `w1 w2 w3` || `'w1' OR 'w2' OR 'w3'` ||
|| `w1 w2 +w3` || `('w1' OR 'w2') AND 'w3'` ||
|| `w1 +w2 +w3` || `('w1') AND ('w2' AND 'w3')` ||

Query words with the `-` operator will be excluded.

== Annotation Features ==

Users can annotate entries with their own study notes on the site. They can share those notes with other users or publish them to all users.

  * To add a note, the (logged-in) user selects a piece of text in the entry, and presses the 'add-note' button, after which a text dialog appears in which the not can be edited.
  * The user note is stored, and displayed in the margin whenever the end entry is shown.
  * To share a note with another (known) user, the user presses 'share' and enters the other user's email address; after this, the addressed user will receive an email notification.
  * To publish a note, the user presses 'publish' and the note will become visible to all users.

== Administrative Features ==

Since the site allows user-generated content, several measures need to be taken to monitor its usage and prevent abuse of those features.

  * Administrators should have a convenient view on published notes.
  * Users publishing notes should be have a user account, containing at least of an (verified) email-address plus password.
  * Publishing of dubious notes (i.e. containing irrelevant content, hyperlinks, or out-of-context) should be easy to undo (by pressing 'unpublish' or 'delete' by an administrator or editor)
  * Repeat sources of abuse should be blocked by email address or IP address or range (by pressing 'block ip' or 'block email').

== User Administration Features ==

To control abuse, we need to create users, so we can identify and possibly lock-out users who abuse the system. We are not interested in the actual identity of our users, be require some minimal effort to limit automated abuse of our systems.

  * Users can create a user account by providing an email address and a password. The email address should be validated, and the password should meet minimum complexity requirements. Optionally, we can ask for further user information, such as real and nick names and language proficiency.
  * The email address will be verified by sending a url with a unique random token to the indicated address. The user account will be activated once the url is followed.
  * An audit trail will be maintained, retaining the user-id, time-stamp and IP used to access the site for every visit.
  * Users can request a password change by providing their email address. In response to this request, an email will be send with a url with a unique random token. Following this url within a certain time-frame will enable the user to select a new password. Until the password is thus changed, the old will remain valid.
  * Administrators can observe user activities to detect abusive behavior, and can block abusive users.
  * Any email send by the system should contain a link to permanently block the email address for automatic mails generated by the system.