# Makefile.am for support/src

yncludedir = @yncludedir@/support

client_DATA =			\
	support.ycp		\
	support_auto.ycp	\
	support_proposal.ycp

ynclude_DATA =			\
	helps.ycp		\
	wizards.ycp		\
	dialogs.ycp		\
	complex.ycp 		\
	supportconfig_conf.ycp

desktop_DATA =			\
	support.desktop

module_DATA =			\
	Support.ycp		

# create a symlink for local build, #145327
support:
	ln -sf . $@
ycpchook = support

EXTRA_DIST = $(client_DATA) $(ynclude_DATA) $(module_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
