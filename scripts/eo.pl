#!/usr/bin/perl
#
# Author: Björn Jacke <bjacke@suse.de>
#
# version 2001-01-11

use Getopt::Std;

# options:
#	-u lsusb -v
#	-p lspci -vv
#	-r rpm -qa
#	-m lsmod
#	-b /var/log/boot.msg
#	-v /var/log/messages
#	-s generic software config
#	-l /etc/lilo.conf
#	-f /etc/fstab
#	-x /etc/XF86Config, /etc/X11/XF86Config, `ls -la /usr/X11R6/bin/XFree86`
#	-P /etc/printcap
#	-X /var/log/XFree86.0.log
#	-R /etc/rc.config
#	-F `fdisk -l`
#	-M /etc/modules.conf

getopts('purmbsvMFRXPxfl') or die "unknown option!";


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


## `fdisk -l`

if ($opt_F) {
	push @out_fdisk, "##Y2support-fdisk:\n";
	for (`/sbin/fdisk -l 2>&1`) {
		push @out_fdisk, $_;
	}
	my $len=$#out_fdisk;
	push @out_fdisk, "##Y2support-fdisk--$len\n";
}


## /var/log/boot.msg

if ($opt_b) {
	push @out_boot, "##Y2support-boot:\n";
	open(BB, "< /var/log/boot.msg") or print "can't open /var/log/boot.msg: $!";
	push @out_boot, $_ while (<BB>);
	close(BB);
	my $len=$#out_boot;
	push @out_boot, "##Y2support-boot--$len\n";
}


## /etc/rc.config

if ($opt_R) {
	push @out_rcconfig, "##Y2support-rcconfig:\n";
	open(BB, "< /etc/rc.config") or print "can't open /etc/rc.config: $!";
	push @out_rcconfig, $_ while (<BB>);
	close(BB);
	my $len=$#out_rcconfig;
	push @out_rcconfig, "##Y2support-rcconfig--$len\n";
}


## -X /var/log/XFree86.0.log

if ($opt_X) {
	push @out_Xlog, "##Y2support-XFree86.0.log:\n";
	open(BB, "< /var/log/XFree86.0.log") or print "can't open /var/log/XFree86.0.log: $!";
	push @out_Xlog, $_ while (<BB>);
	close(BB);
	my $len=$#out_Xlog;
	push @out_Xlog, "##Y2support-XFree86.0.log--$len\n";
}


## /etc/fstab

if ($opt_f) {
	push @out_fstab, "##Y2support-fstab:\n";
	open(BB, "< /etc/fstab") or print "can't open /etc/fstab: $!";
	push @out_fstab, $_ while (<BB>);
	close(BB);
	my $len=$#out_fstab;
	push @out_fstab, "##Y2support-fstab--$len\n";
}


## /etc/modules_conf

if ($opt_M) {
	push @out_modconf, "##Y2support-modconf:\n";
	open(BB, "< /etc/modules.conf") or print "can't open /etc/modules.conf: $!";
	push @out_modconf, $_ while (<BB>);
	close(BB);
	my $len=$#out_modconf;
	push @out_modconf, "##Y2support-modconf--$len\n";
}


## X config files
#       -x /etc/XF86Config, /etc/X11/XF86Config, `ls -la /usr/X11R6/bin/XFree86`

if ($opt_x) {
	push @out_X, "##Y2support-X:\n";
	
	push @out_X, "##Y2support-XF86Config3:\n";
	open(BB, "< /etc/XF86Config") or print "can't open /etc/XF86Config: $!";
	push @out_X, $_ while (<BB>);
	close(BB);
	push @out_X, "##Y2support-XF86Config3--\n";

	push @out_X, `/bin/ls -la /usr/X11R6/bin/XFree86`;

	push @out_X, "##Y2support-XF86Config4:\n";
	open(BB, "< /etc/X11/XF86Config") or print "can't open /etc/X11/XF86Config: $!";
	push @out_X, $_ while (<BB>);
	close(BB);
	push @out_X, "##Y2support-XF86Config4--\n";
	my $len=$#out_X;
	push @out_X, "##Y2support-X--$len\n";
}


## /etc/lilo.conf

if ($opt_l) {
	push @out_lilo, "##Y2support-lilo:\n";
	open(BB, "< /etc/lilo.conf") or print "can't open /etc/lilo.conf: $!";
	push @out_lilo, $_ while (<BB>);
	close(BB);
	my $len=$#out_lilo;
	push @out_lilo, "##Y2support-lilo--$len\n";
}


## /etc/printcap

if ($opt_P) {
	push @out_print, "##Y2support-print:\n";
	open(BB, "< /etc/printcap") or print "can't open /etc/printcap: $!";
	push @out_print, $_ while (<BB>);
	close(BB);
	my $len=$#out_print;
	push @out_print, "##Y2support-print--$len\n";
}


## /var/log/messages

if ($opt_v) {
	push @out_mess, "##Y2support-messages:\n";
	push @out_mess, `/usr/bin/tail -n 250 /var/log/messages` or print "can't open /var/log/messages: $!";
	my $len=$#out_mess;
	push @out_mess, "##Y2support-messages--$len\n";
}


## df etc. al
if ($opt_s) {
	push @out_df, "##Y2support-df:\n";
	for (`/bin/df`) {
		push @out_df, $_;
	}
	my $len=$#out_df;
	push @out_df, "##Y2support-df--$len\n";

	push @out_df, "##Y2support-uptime:\n";
	for (`/usr/bin/uptime`) {
		push @out_df, $_;
	}
	$len=$#out_df;
	push @out_df, "##Y2support-uptime--$len\n";
	
	push @out_df, "##Y2support-release:\n";
	open(REL, "< /etc/SuSE-release") or print "can't open /etc/SuSE-release: $!";
	push @out_df, $_ while (<REL>);
	close(REL);
	my $len=$#out_df;
	push @out_df, "##Y2support-release--$len\n";
}

for (@out_boot,@out_mess,@out_mod,@out_pci,@out_rpm,@out_usb,@out_df,@out_lilo,@out_print,@out_X,@out_Xlog,@out_fstab,@out_rcconfig,@out_modconf,@out_fdisk) {
	print if $_;
}
