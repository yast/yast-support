# Makefile.am for support/src

yncludedir = @yncludedir@/support

ynclude_DATA = supportio.ycp

client_DATA =			\
	support.ycp		\
	support_askkey.ycp	\
	support_question.ycp	\
	support_send.ycp	\
	view_anymsg.ycp

desktop_DATA =			\
	support.desktop		\
	messages.desktop	\
	bootmsg.desktop

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
