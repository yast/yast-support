#
# Makefile.am for y2m_support/src
#

modulesdir = $(YAST2DIR)/clients
menudir = $(YAST2DIR)/menuentries
includedir = $(YAST2DIR)/include/support
scriptdir = $(YAST2DIR)/bin

regdir = /var/lib/support

reg_DATA = rc.registration
reg_SCRIPTS = eo.pl send_support_request.pl

script_SCRIPTS = is_suse_there.sh

modules_SCRIPTS =			\
	support.ycp			\
	support_registration.ycp	\
	support_question.ycp		\
	support_send.ycp

include_HEADERS =	\
	registration.ycp

menu_SCRIPTS = menuentry_support.ycp

EXTRA_DIST = $(modules_SCRIPTS) $(menu_SCRIPTS) \
	     $(reg_DATA) $(reg_SCRIPTS)		\
	     $(script_SCRIPTS)

install-data-hook:
	chmod 700 $(regdir)
