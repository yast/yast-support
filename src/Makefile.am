#
# Makefile.am for y2m_support/src
#

modulesdir = $(YAST2DIR)/clients
menudir = $(YAST2DIR)/menuentries
includedir = $(YAST2DIR)/include/support

regdir = /var/lib/support

reg_DATA = rc.registration

modules_SCRIPTS =			\
	support.ycp			\
	support_registration.ycp	\
	support_question.ycp		\
	support_send.ycp

include_HEADERS =	\
	registration.ycp

menu_SCRIPTS = menuentry_support.ycp

EXTRA_DIST = $(modules_SCRIPTS) $(menu_SCRIPTS) $(reg_DATA)

install-data-hook:
	chgrp users $(regdir)
	chmod og+w $(regdir)
	chgrp users $(regdir)/$(reg_DATA)
	chmod og+w $(regdir)/$(reg_DATA)
