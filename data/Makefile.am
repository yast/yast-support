#
# Makefile.am for y2m_support/data
#

keydir = $(DESTDIR)/var/lib/support

key_DATA = key filenames

EXTRA_DIST = $(key_DATA)

install-data-hook:
	$(mkinstalldirs) $(keydir)
	chmod 700 $(keydir)
