#
# Makefile.am for support/src
#
supportdir = $(yincludedir)/support

support_HEADERS = supportio.ycp
client_SCRIPTS =		\
	support.ycp		\
	support_askkey.ycp	\
	support_question.ycp	\
	support_send.ycp	\
	view_anymsg.ycp

config_SCRIPTS = 	\
	menuentry_support.y2cc	\
	menuentry_messages.y2cc	\
	menuentry_bootmsg.y2cc

EXTRA_DIST = $(client_SCRIPTS) $(config_SCRIPTS)
