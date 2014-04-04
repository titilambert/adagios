Translathon
===========

You'll get assigned a block of files, whose list is in the file 'to_translate'.


# Links #

  - example of what to do: https://github.com/matthieucan/adagios/commit/b7656181a6837ee70498763b0eb444f88c3a73e5

# Template files (*.html) #

    <h1>Hello, world</h1>

   *will become*

    <h1>{% trad "Hello, world" %}</h1>


# Python files (*.py) #

    def foo(bar1, bar2, g='This is text'):
      s = "another string %d and %d" % (bar1, bar2)
      return('yet another one')

  *will become*

    def foo(barm g=_('This is text'))
      s = _("another string %(bar1)d and %(bar2)d") % {'bar1': bar1, 'bar2': bar2}
      return(_('yet another one'))


# Translations #

Translate .po files located in locale/fr/, using e.g. Poedit.
