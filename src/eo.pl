#!/usr/bin/perl
#
# Author: Björn Jacke <bjacke@suse.de>
#

use Getopt::Std;

# options:
#	-u lsusb -v
#	-p lspci -vv
#	-r rpm -qa
#	-m lsmod
#	-b /var/log/boot.msg
#	-v /var/log/messages
#	-s generic software config

getopts('purmbsv') or die "unknown option!";


## PCI

if ($opt_p) {
	push @out_pci, "##Y2support-pci:\n";
	for (`/sbin/lspci -vv`) {
		push @out_pci, $_;
	}
	my $len=$#out_pci;
	push @out_pci, "##Y2support-pci--$len\n";
}


## USB

if ($opt_u) {
	push @out_usb, "##Y2support-usb:\n";
	for (`/sbin/lsusb -v`) {
		push @out_usb, $_;
	}
	my $len=$#out_usb;
	push @out_usb, "##Y2support-usb--$len\n";
}


## RPM

if ($opt_r) {
	push @out_rpm, "##Y2support-rpm:\n";
	for (`/bin/rpm -qa`) {
		push @out_rpm, $_;
	}
	my $len=$#out_rpm;
	push @out_rpm, "##Y2support-rpm--$len\n";
}


## lsmod

if ($opt_m) {
	push @out_mod, "##Y2support-mod:\n";
	for (`/sbin/lsmod`) {
		push @out_mod, $_;
	}
	my $len=$#out_mod;
	push @out_mod, "##Y2support-mod--$len\n";
}


## /var/lob/boot.msg

if ($opt_b) {
	push @out_boot, "##Y2support-boot:\n";
	open(BB, "< /var/log/boot.msg") or print "can't open /var/log/boot.msg: $!";
	push @out_boot, $_ while (<BB>);
	close(BB);
	my $len=$#out_boot;
	push @out_boot, "##Y2support-boot--$len\n";
}


## /var/log/messages

if ($opt_v) {
	push @out_mess, "##Y2support-messages:\n";
	push @out_mess, `/usr/bin/tail -n 250 /var/log/messages` or print "can't open /car/log/messages: $!";
	my $len=$#out_mess;
	push @out_mess, "##Y2support-messages--$len\n";
}


if ($opt_s) {
	
	## df

	push @out_df, "##Y2support-df:\n";
	for (`/bin/df`) {
	push @out_df, $_;
	}
	my $len=$#out_df;
	push @out_df, "##Y2support-df--$len\n";

	print `/usr/bin/uptime`;
	open(REL, "< /etc/SuSE-release") or print "can't open /etc/SuSE-release: $!";
	print while (<REL>);
	close(REL);
}

for (@out_boot,@out_mess,@out_mod,@out_pci,@out_rpm,@out_usb,@out_df,@out) {
	print if $_;
}
