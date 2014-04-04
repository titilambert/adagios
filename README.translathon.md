Translathon
===========

You'll get assigned a block of files, whose list is in the file 'to_translate'.


Template files (*.html)
=======================

<h1>Hello, world</h1>

   will become

<h1>{% trad "Hello, world" %}</h1>


Python files (*.py)
===================

def foo(bar, g='This is text'):
  s = 'another string'
  return('yet another one')

  will become

def foo(barm g=_('This is text'))
  s = _('another atring')
  return(_('yet another one'))


Translations
============

Translate .po files located in locale/fr/, using e.g. Poedit.
