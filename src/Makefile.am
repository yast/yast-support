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
	support.y2cc	\
	messages.y2cc	\
	bootmsg.y2cc

EXTRA_DIST = $(client_SCRIPTS) $(config_SCRIPTS)
