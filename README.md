vim-rtgram
==========

A no nonsense vim9script plugin without dependencies aimed at running
grammar checks on git commit messages and mail composed using vim,
while at the same time being somewhat functional for plain text files.

The plugin is a wrapper around the open source language checker
languagetool which can be [downloaded](https://www.languagetool.org/download/) and ran locally on your own
machine. In future hopefully an even more open grammar engine without
hints at cloud and subscriptions can be found and this plugin reworked.

There already exists a few vim plugins around languagetool why another
one?

- There is no plugin that focuses on the use-case of checking git commit
  messages and mail composed using vim. Most target either plain text
  files, LaTeX or markdown.
- The existing plugins are either dead and only support the now removed
  XML interface of languagetool or are part of a large lint framework
  that brings in other features.

Usage
=====

```
:RTGramCheck
```
Run the grammar check on the current buffer and insert syntax
highlighting and virtual-text if any issues are found.

```
:RTGramReset
```
Reset he buffer and remove all highlights and virtual-text added by a
check run.

Possible future work
====================

- Allow for the plugin to communicate with languagetool running in HTTP
  server mode.
- Allow a user setting to re-run the check automatically when the buffer
  has changed.
