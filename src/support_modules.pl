#!/usr/bin/perl
#
# Björn Jacke <bjacke@suse.de>, 2001
#

my @allparams = qw(
		boot
		cdr
		dsl
		install
		isdn
		modem
		printer
		scanner
		sound
		x11
		);

for $par (@allparams) {
	for $i (@ARGV) {
		push @mypars, $par if ($i eq "--$par");
	}
}

for $par (@mypars) {
	@commands=();
	@files=();
	do "/usr/lib/YaST2/include/support/$par.include";

	for (@commands) {
		push @outarr, "\n##Y2support-$_:\n";
		push @outarr, `$_`;
		push @outarr, "\n##Y2support-$_--\n";

	}

	for $file (@files) {
		open FH, "< $file" or next;
		push @outarr, "\n##Y2support-$file:\n";
		push @outarr, $_ while (<FH>);
		close FH;
		push @outarr, "\n##Y2support-$file--\n";
	}
}
print for (@outarr);
