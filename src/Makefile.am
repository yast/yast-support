#
# Makefile.am for y2m_support/src
#

modulesdir = $(YAST2DIR)/clients
includedir = $(YAST2DIR)/include/support
menudir = $(YAST2DIR)/menuentries

include_HEADERS = supportio.ycp
modules_SCRIPTS =		\
	support.ycp		\
	support_askkey.ycp	\
	support_question.ycp	\
	support_send.ycp	\
	view_anymsg.ycp

menu_SCRIPTS = 	\
	menuentry_support.y2cc	\
	menuentry_messages.y2cc	\
	menuentry_bootmsg.y2cc

EXTRA_DIST = $(modules_SCRIPTS) $(menu_SCRIPTS)
