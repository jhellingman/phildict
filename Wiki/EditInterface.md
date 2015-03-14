#summary Edit interface to allow on-line edits.

= Introduction =

An edit-interface to the data, to allow on-line edits to the raw data.

== Requirements ==

  * Retain history of changes.
  * Diff-view, both of tagged and 'tag-stripped' data.
  * Edit directly in XML format.
  * Validate XML format before accepting it (preferably on the client)
  * Use template to generate forms for conjugated forms and other information.
  * Converted submitted forms back to filled-in template.
  * Allow split/merge of entries.
  * Update indexes after every edit to reflect current data.

== Template Structure ==

A simple template could look like this.

{{{
<entry>
   <form><t:input label="Word"/></from>
   <trans><t:input label="Translation"/></trans>
</entry>
}}}


And would be rendered to a form with two input boxes.

After saving the form, the following entry could be constructed.

{{{
<entry>
   <form><t:input label="Word">WORD-FORM</t:input></from>
   <trans><t:input label="Translation">TRANSLATION</t:input</trans>
</entry>
}}}

Dropping the elements in the `t:` namespace (but not their content) will be used for display purposes.