#!/usr/bin/perl 

use Getopt::Long;

my $siprt_mode = ""; 
my $outfile = ""; 
my $printhelp;
GetOptions (	'output=s'	=> \$siprt_mode, 
		'file=s' 	=> \$outfile, 
	     	'help'		=> \$printhelp
	   );

my $PREFIX = "/usr"; 
my $RPM = "/bin/rpm"; 
my $LS = "/bin/ls"; 
my $HWINFO = "/usr/sbin/hwinfo";

$ENV{PATH} = ""; chomp(my $HOSTNAME = `/bin/hostname -f`);

my $UNAME = `/bin/uname -a`; 
my $UNAMER = `/bin/uname -r`; 
my $SuSE_release = `/usr/bin/head -1 /etc/SuSE-release`;

my $now_string = localtime();
my %proc_h = ();
my $machinetype = `/bin/uname -m`;
my $config_dir = "/var/lib/support/";

#
# $html_header
#
my $html_header    = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"
  \"http://www.w3.org/TR/REC-html40/loose.dtd\">
<html>
  <head>
  <style type=\"text/css\" media=\"screen\">
  <!--
    BODY            { background: #FFFFFF; color: #000000; font-family: sans-serif; }
    table           { font-family: sans-serif; }
    P               { font-family: serif; text-align: justify; text-indent: 1em; }
    H1,H2,H3,H4,H5  { font-family: sans-serif }
    H1.noextraskip  { font-size: large; }
    H2.noextraskip  { font-size: medium; }
    H1              { font-size: large ; line-height: 200%; text-align: center; }
    H2              { font-size: medium; line-height: 150%; text-align: center; }
    H3              { font-size: medium; line-height: 120%; text-align: center; }
    PRE             { font-family: sans-serif; text-indent: 0em; font-size: small; }
    TABLE           { font-family: sans-serif; text-indent: 0em; font-size: normal; }
    TABLE.small     { font-family: sans-serif; text-indent: 0em; font-size: small; }
    TH              { font-family: sans-serif; text-indent: 0em; text-align: left; font-size: small; }
    TD              { font-family: sans-serif; text-indent: 0em; text-align: left; font-size: small; }
    UL P            { text-indent: 0em; list-style: disc outside; text-align: left; margin-left: 0em; }
    OL P            { text-indent: 0em; }
    UL              { margin-left: 0em; list-style-type: disc outside; 
                      text-align: left ; text-indent: 0em; font-family: sans-serif; }
    UL.toc          { margin-left: 0em; list-style-type: none ;
                      text-align: left ; text-indent: 0em; font-family: sans-serif; }
    STRONG          { font-style: normal; font-weight: bold; }
    EM              { font-style: italic; }
    ADDRESS         { font-family: sans-serif; font-style: italic; }
  -->
  </style>
    <title>$HOSTNAME, $now_string</title>
</head>
<body bgcolor=\"#FFFFFF\">
  <table summary=\"header\" border=\"0\" width=\"100%\">
    <tr>
      <td valign=\"bottom\"><h1>$HOSTNAME, $now_string</h1></td>
    </tr>
    <tr>
      <td valign=\"top\"><h2>$UNAME<br>$SuSE_release</h2></td>
    </tr>
  </table>
  <hr>";
my  $html_footer ="<hr>
<address>&copy; 2001 SuSE Linux AG</address>
</html>\n";

#
# $tex_header
#
$UNAME	  =~ s/\_/\\_/g;
$UNAME	  =~ s/\#/\\\#/g;
my $tex_header = "\\documentclass[a4paper,11pt,headinclude,a4paper]\{scrartcl\} 
\\usepackage[latin1]\{inputenc\} 
% \\usepackage[headinclude,a4paper]\{typearea\} 
\\areaset\{40em\}\{50\\baselineskip\} 
\\usepackage\{epsfig,longtable,verbatim,multicol\} 
\\pagestyle\{plain\} 
% \\usepackage\{german\} 
% \\selectlanguage\{english\} 
% 
\\newcommand\{\\tm\}\{\\texttrademark\} 
% 
\\begin\{document\} 
\\title\{$HOSTNAME, $now_string \\\\
\{\\normalsize $UNAME\\ $SuSE_release\} \}
\\author\{$RELEASE \\textcopyright{} 2001 by SuSE Linux AG\}
\\maketitle
\\tableofcontents 
\\newpage
";
my $tex_footer="\n\\end\{document\}\n";
my $old_tex_footer = "\n
\\par\\noindent
\\textsf{\\textcopyright{} 2001 SuSE Linux AG}\\par
\\end\{document\}\n";


#
# Table of contents
#
my  $seccnt=0;
my  $subseccnt=0;
my  $subsubseccnt=0;
my  $OutputBuffer="";
my  $TOCBuffer="";
my  $lastTOClevel=0;
my  $IsVerbatim=0;

sub mysprint {
  $OutputBuffer = join "", $OutputBuffer, @_;
}

sub addtoc($$$){
  my ($level, $ancor, $value) = @_;  
  if($level>$lastTOClevel){
    $TOCBuffer = join "", $TOCBuffer, "<ul class=\"toc\">\n";
  }elsif($level<$lastTOClevel){
    $TOCBuffer = join "", $TOCBuffer, "</li>\n</ul>\n</li>\n";
  }elsif($lastTOClevel!=0){
    $TOCBuffer = join "", $TOCBuffer, "</li>\n";
  }else{}
  $TOCBuffer = join "", $TOCBuffer, 
               "<li><a href=\"#",$ancor,"\">",$value,"</a>\n";  
  $lastTOClevel=$level;
}

sub siprint($$$) {
  my ($m, $value, $attr) = @_;
  if($siprt_mode eq "html") {
    $value =~ s/\&/\&amp;/g;
    $value =~ s/</\&lt;/g;
    $value =~ s/>/\&gt;/g;
    if($m eq "h1")       {
      $seccnt++;
      mysprint 
	"<h1><a name=\"",$seccnt,"\"\n>",$seccnt,".&nbsp;",$value,"</a></h1>";
      addtoc(1, "$seccnt", "$seccnt.&nbsp;$value");
      $subseccnt=0;
    }
    if($m eq "h2")       {
      $subseccnt++;
      mysprint 
	"<h2><a name=\"",$seccnt,".",$subseccnt,"\"\n>",
	$seccnt,".",$subseccnt,"&nbsp;",$value,"</a></h2>";
      addtoc(2, "$seccnt.$subseccnt", "$seccnt.$subseccnt&nbsp;$value");
      $subsubseccnt=0;
    }
    if($m eq "h3")       {
      $subsubseccnt++;
      mysprint 
	"<h3><a name=\"",$seccnt,".",$subseccnt,".",$subsubseccnt,"\"\n>",
	$seccnt,".",$subseccnt,".",$subsubseccnt,"&nbsp;",$value,"</a></h3>";
    }
    if($m eq "tabborder"){mysprint "<table summary=\"\"\n border=\"1\">";}
    if($m eq "tab")      {mysprint "<table summary=\"\"\n border=\"0\">";}
    if($m eq "endtab")   {mysprint "</table>\n";}
    if($m eq "tabrow")   {mysprint "<tr\n>";}
    if($m eq "endrow")   {mysprint "</tr>\n";}
    if($m eq "pre")      {mysprint "<pre>"; $IsVerbatim=1;}
    if($m eq "endpre")   {mysprint "</pre>\n"; $IsVerbatim=0;}
    if($m eq "multipre") {mysprint "<pre>";$IsVerbatim=1;}
    if($m eq "endmultipre"){mysprint "</pre>\n";$IsVerbatim=0;}
    if($m eq "cellspan") {mysprint "<td \nnowrap colspan=\"",$attr,"\">",$value,"</td>";}
    if($m eq "cell")     {mysprint "<td \nnowrap>",$value,"</td>";}
    if($m eq "cellwrap") {mysprint "<td>",$value,"</td>";}
    if($m eq "cellcolor"){mysprint "<td bgcolor=\"",$attr,"\" \nnowrap>",$value,"</td>";}
    if($m eq "headcolor"){mysprint "<th bgcolor=\"",$attr,"\" \nnowrap>",$value,"</th>";}
    if($m eq "tabhead")  {mysprint "<th \nnowrap>",$value,"</th>";}
    if($m eq "headcols") {mysprint "<th \nnowrap colspan=\"",$attr,"\">",$value,"</th>";}
    if($m eq "verb")     {mysprint $value;}
    if($m eq "header")   {print $html_header;}
    if($m eq "toc")      {
      for($ii=$lastTOClevel; $ii>0; $ii--){
        $TOCBuffer = join "", $TOCBuffer, "</li>\n</ul>\n";
      }
      print "<h1>Table of Contents</h1>\n",$TOCBuffer;
    }
    if($m eq "body")     {print $OutputBuffer;}
    if($m eq "footer")   {print $html_footer;}
  }elsif( $siprt_mode eq "tex" || $siprt_mode eq "latex" ) {
    if($IsVerbatim==0) {
      $value =~ s/\_/\\_/g;
      $value =~ s/\#/\\\#/g;
      $value =~ s/%/\\%/g;
      $value =~ s/\&/\\\&/g;
    }
    ## s/(\")(\w)/\"\`$2/g; s/(\w)(\")/$1\"\'/g; s/([.,;?!])(\")/$1\"\'/g;
    if($m eq "h1")       {print "\\section\{",$value,"\}\n";}
    if($m eq "h2")       {print "\\subsection\{",$value,"\}\n";}
    if($m eq "h3")       {print "\\subsubsection\{",$value,"\}\n";}
    if($m eq "tabborder"){print
			    "\\begingroup\\scriptsize\\par",  
			    "\\noindent\\begin\{longtable\}[l]\{\@\{\}",
			    $value,"l\@\{\}\}\n";
    }
    if($m eq "tab")      {print
			    "\\begingroup\\scriptsize\\par",  
			    "\\noindent\\begin\{longtable\}[l]\{\@\{\}",
			    $value,"l\@\{\}\}\n";
    }
    if($m eq "endtab")   {print "\\end\{longtable\}\\par\\endgroup\n";}
    if($m eq "tabrow")   {}
    if($m eq "endrow")   {print "\\\\\n";}
    if($m eq "pre")      {print "\\begin\{verbatim\}";$IsVerbatim=1;}
    if($m eq "endpre")   {print "\\end\{verbatim\}\n";$IsVerbatim=0;}
    if($m eq "multipre") {
      print "\n\\par\\begingroup\\scriptsize\\par\n";
      print "\\begin\{multicols\}\{2\}\n\\begin\{verbatim\}\n";
      $IsVerbatim=1;
    }
    if($m eq "endmultipre"){
      print "\\end\{verbatim\}\n";
      print "\\end\{multicols\}\\par\\endgroup\\par\n";
      $IsVerbatim=0;
    }
    if($m eq "cellspan") {print $value,"\&";}
    if($m eq "cell")     {print $value,"\&";}
    if($m eq "cellwrap") {print $value,"\&";}
    if($m eq "cellcolor"){print $value,"\&";}
    if($m eq "headcolor"){print $value,"\&";}
    if($m eq "tabhead")  {print $value,"\&";}
    if($m eq "headcols") {print $value,"\&";}
    if($m eq "verb")     {print $value;}
    if($m eq "header")   { print $tex_header; }
    if($m eq "footer")   {print $tex_footer;}
  }elsif($siprt_mode eq "sql") {
  }
}
sub siprt($)    {my($t1) = shift(@_);siprint($t1,"","");}
sub siprtt($$)  {my($t1,$t2) = @_;siprint($t1, $t2,"");}
sub siprttt($$$){my($t1,$t2,$t3) = @_;siprint($t1,$t2,$t3);}

sub si_cpu_and_memory() {
  siprtt("h1","cpu and memory"); 
  siprtt("tabborder","ll");
  open(IN, "/proc/cpuinfo");
  chomp($machinetype);
  if($machinetype eq "alpha"){
    while (<IN>) {
      my ($proc, $value) = split /:/;
      chop($proc);
      chop($value);
      if($proc eq "cpus detected"){
        siprt("tabrow");siprttt("headcolor","cpus detected", "\#CCCCCC");
        siprttt("cellcolor",$value, "\#CCCCCC");siprt("endrow");
      }else{
        siprt("tabrow");siprtt("tabhead",$proc);
        siprtt("cell",$value);siprt("endrow");
      }
    }
  }else{
    while (<IN>) {
      if(m/processor/gi){
        # m/(\d+)/gs;
        my ($proc, $value) = split /:/;
        siprt("tabrow");siprttt("headcolor","Processor", "\#CCCCCC");
        siprttt("cellcolor",$value, "\#CCCCCC");siprt("endrow");
      }
      if(m/^(cpu MHz)|^(model name)|^(vendor_id)|^(cache size)|^(stepping)|^(cpu family)|^(model)/i){
        m/^(.*):(.*)$/gsi;
        my $tt1 = $1;
        chop(my $tt2 = $2);
        siprt("tabrow");siprtt("tabhead",$tt1);siprtt("cell",$tt2);siprt("endrow");
      }
    }
  } 
  close(IN);
  open(IN, "/proc/meminfo");
  while (<IN>) {
    if(m/MemTotal/g){
      m/(\d+)/gs; 
      siprt("tabrow");siprtt("tabhead","Main Memory");
      siprtt("cell","$1 KByte");siprt("endrow");
    }
  } 
  close(IN);
  siprt("endtab");
}

sub si_pnp() {
  if(-r "/sbin/lspnp"){
    open(IN, "/sbin/lspnp | ");
    siprtt("h2","PNP-Devices");
    siprtt("tabborder","lll");
    siprt("tabrow");siprtt("tabhead","Node Number");
    siprtt("tabhead","Product Ident.");
    siprtt("tabhead","Description");
    siprt("endrow");
    my @attr;
    while (<IN>) {
      @attr = split /\s+/,$_, 3;
      siprt("tabrow");
      siprtt("cell",$attr[0]);
      siprtt("cell",$attr[1]);
      siprtt("cell",$attr[2]);
      siprt("endrow");
    } 
    siprt("endtab");
    close(IN);
  }
}

sub si_pci() {
  open(IN, "/proc/pci");
  siprtt("h2","PCI-Devices");
  siprtt("tabborder","lllll");
  siprt("tabrow");siprtt("tabhead","Type");siprtt("tabhead","Vendor/Name");
  siprtt("tabhead","Bus");siprtt("tabhead","Device");
  siprtt("tabhead","Function");siprt("endrow");
  my @attr;
  while (<IN>) {
    if(m/:$/g){
      # s/^\s+Bus\s+(\d+),\s+device\s+(\d+),\s+function\s+(\d+):$/$1:$2:$3/gx;
      m/^\s+Bus\s+(\d+),\s+device\s+(\d+),\s+function\s+(\d+)/;
      @attr = ($1, $2, $3);
    }elsif(m/:/g){
      m/^(.*):(.*)/;
      siprt("tabrow");siprtt("cell",$1);siprtt("cell",$2);siprtt("cell",$attr[0]);
      siprtt("cell",$attr[1]);siprtt("cell",$attr[2]);siprt("endrow");
    }
  } 
  siprt("endtab");
  close(IN);
}

sub si_lsdev() {
  #	lsdev.pl
  #	Created by Sander van Malssen <svm@ava.kozmix.cistron.nl>
  #	Date:        1996-01-22 19:06:22
  #	Last Change: 1998-05-31 15:26:58
  #       $Id$
  my %device_h = ();
  use vars qw($device_h @line $line @tmp $tmp0 $name %port $abc $hddev);
  my %dma      = ();
  my %irq      = ();
  open (IRQ, "/proc/interrupts") || return();
  while (<IRQ>) {
    next if /^[ \t]*[A-Z]/;
    chop;
    my $n;
    if (/PIC/) {
      $n = (@line = split());
    } else {
      $n = (@line = split(' [ +] '));
    }
    my $name = $line[$n-1];
    $device_h{$name} = $name;
    @tmp = split(':', $line[0]);
    $tmp0 = int($tmp[0]);
    $irq{$name} = "$irq{$name} $tmp0";
  }
  close (IRQ);
  open (DMA, "/proc/dma") || return() ;
  while (<DMA>) {
    chop;
    @line = split(': ');
    @tmp = split (/[ \(]/, $line[1]);
    $name = $tmp[0];
    $device_h{$name} = $name;
    $dma{$name} = "$dma{$name}$line[0]";
  }
  close (DMA);
  open (IOPORTS, "</proc/ioports") || return();
  while (<IOPORTS>) {
    chop;
    @line = split(' : ');
    @tmp = split (/[ \(]/, $line[1]);
    $name = $tmp[0];
    $device_h{$name} = $name;
  $port{$name} = "$port{$name} $line[0]";
  }
  close (IOPORTS);
  siprtt("h1","Devices");
  siprtt("tabborder","llll");
  siprt("tabrow");siprtt("tabhead","Device");siprtt("tabhead","DMA");
  siprtt("tabhead","IRQ");siprtt("tabhead","I/O Ports");siprt("endrow");
  foreach $name (sort { uc($a) cmp uc($b) } keys %device_h) {
    siprt("tabrow");siprtt("cell",$name);siprtt("cell",$dma{$name});
    siprtt("cell",$irq{$name});siprtt("cell",$port{$name});siprt("endrow");
  }
  siprt("endtab");
}

sub si_ide() {
  my $exists_ide=0;
  for $abc ("a".."d") {
    if(-r "/proc/ide/hd$abc") {$exists_ide=1;}
  }
  if($exists_ide){
    if($UNAMER lt "2.1.0") {
      siprtt("h1","IDE-Analysis: Kernel-Release $UNAMER not supported, sorry :-(\n");    
    }else{
      siprtt("h1","IDE-Hard-Discs");
      siprtt("tabborder","lllllllll");
      siprt("tabrow");siprtt("tabhead","Device");siprtt("tabhead","Type");
      siprtt("tabhead","Model");siprtt("tabhead","Driver");
      siprtt("tabhead","Geo., phys.");siprtt("tabhead","Geo., log.");
      siprtt("tabhead","Size(blks)");siprtt("tabhead","Firmware");
      siprtt("tabhead","Serial");
      siprt("endrow");
      for $abc ("a".."d") {
	if(-r "/proc/ide/hd$abc") {
	  $hddev = "/dev/hd$abc";
	  chomp($media=`/bin/cat /proc/ide/hd${abc}/media`);
	  chomp($driver=`/bin/cat /proc/ide/hd${abc}/driver`);
	  chomp($model=`/bin/cat /proc/ide/hd${abc}/model`);
	  siprt("tabrow");siprtt("cell","/dev/hd$abc");siprtt("cell",$media);
	  siprtt("cell",$model);siprtt("cell",$driver);
	  if($media eq "disk") {
	    $capa   = `/bin/cat /proc/ide/hd${abc}/capacity`;
	    $cache	= `/bin/cat /proc/ide/hd${abc}/cache`;
	    open(GEO,"/proc/ide/hd${abc}/geometry ");
	    while(<GEO>) {
	      if(m/^logical/g){s/^logical\s+(.*)$/$1/gs; $geol=$_;}
	      if(m/^physical/g){s/^physical\s+(.*)$/$1/gs; $geop=$_;}
	    }
	    close(GEO);
	    # open(IDEINFO,"$HWINFO --disk | ");
	    # while(<IDEINFO>) {
	    #   if(m/FW_REV/g){s/FW_REV=\"(.*)\"$/$1/gs; $fw_rev=$_;}
	    #   if(m/SERIAL_NO/g){s/SERIAL_NO=\"(.*)\"$/$1/gs; $serial=$_;}
	    # }
	    close(IDEINFO);
	    siprtt("cell",$geop);
	    siprtt("cell",$geol);
	    siprtt("cell",$capa);
	    # siprtt("cell",$fw_rev);
	    # siprtt("cell",$serial)
	    siprtt("cell","-");
	    siprtt("cell","-")
	  }else{
	    siprttt("headcol", "", "5");
	  }
	  siprt("endrow");
	}
      }
      siprt("endtab");
    }
  }
}

sub si_dac960() {
  if(-r "/proc/rd") {
    siprtt("h1","Mylex ('DAC 960') Raid");
    for ($i=0; $i<8; $i++) {
      if(-r "/proc/rd/c$i"){
	siprtt("h2","Controller $i");
	open(MYLEX, "/proc/rd/c$i/initial_status");
	siprtt("tabborder","lllllll");
	my $status;
	my %physicals=();
	my $onephysical;
	my $first = 1;
	my $open = 0;
	while(<MYLEX>) {
	  # print $_;
	  if(m/^Configuring/){
	    $status="config";
	  }elsif($status eq "config" && m/^\s\sPhysical/){
	    siprt("endtab");
	    $status="physical";
	    siprtt("tabborder","");
	    siprt("tabrow");siprtt("tabhead","id:lun");siprtt("tabhead","Vendor");
	    siprtt("tabhead","Model");siprtt("tabhead","Revision");
	    siprtt("tabhead","Serial");siprtt("tabhead","Status");
	    siprtt("tabhead","Size");siprt("endrow");
	  }elsif($status eq "physical" && m/^\s\sLogical/){
	    siprt("endrow");
	    siprt("endtab");
	    $status="logical";
	    siprtt("tabborder","lllll");
	    siprt("tabrow");
	    siprtt("tabhead","Device");siprtt("tabhead","Raid-Level");
	    siprtt("tabhead","Status");siprtt("tabhead","Size");
	    siprtt("tabhead","Options");
	    siprt("endrow");
	  }elsif($status eq "config" && m/^\s\s\w/){
	    chomp(@fs = split /:|,/);
	    if($fs[1] ne ""){siprt("tabrow");siprtt("tabhead",$fs[0]);
			     siprtt("cell",$fs[1]);siprt("endrow");}
	    if($fs[3] ne ""){siprt("tabrow");siprtt("tabhead",$fs[2]);
			     siprtt("cell",$fs[3]);siprt("endrow");}
	    if($fs[5] ne ""){siprt("tabrow");siprtt("tabhead",$fs[4]);
			     siprtt("cell",$fs[5]);siprt("endrow");}
	  }elsif($status eq "physical" && m/Vendor/){
	    chomp;
	    m/^\s+(\w+):(\w+)\s+Vendor:(.*)Model:(.*)Revision:(.*)$/gs;
	    if($first){$first=0;}else{siprt("endrow");}
	    siprt("tabrow");siprtt("cell","$1:$2");siprtt("cell",$3);
	    siprtt("cell",$4);siprtt("cell",$5);
	  }elsif($status eq "physical" && m/Serial/){
	    chomp(my ($ttt,$serial) = split /:|,/);
	    siprtt("cell",$serial);
	  }elsif($status eq "physical" && m/Disk/){
	    chomp(my ($ttt,$state, $blocks) = split /:|,/);
	    siprtt("cell",$state);siprtt("cell",$blocks);
	  }elsif($status eq "logical"){
	    chomp(my ($dev,$raid,$state,$blocks,$opt) = split /:|,/);
	    siprt("tabrow");siprtt("cell",$dev);siprtt("cell",$raid);
	    siprtt("cell",$state);siprtt("cell",$blocks);siprtt("cell",$opt);
	    siprt("endrow");
	  }
	}
	siprt("endtab");
	close(MYLEX);
      }
    }
  }
}

sub si_compaq_smart() {
  my $cparray="/proc/array";
  if(-r $cparray){
    siprtt("h1","COMPAQ Smart Array");
    for ($i=0; $i<10; $i++) {
      my $cpa_mode=1;
      if(-r "$cparray/ida$i"){
	siprtt("h2","Controller $i");
	siprtt("tabborder","ll");
	open(SMART, "$cparray/ida$i");
	while(<SMART>) {
	  if(m/^ida\d/ && $cpa_mode==1){
	    @ff = split /:/;
	    siprt("tabrow");siprtt("cell","Typ ($ff[0])");
            siprtt("cell", $ff[1]);siprt("endrow");
	  }elsif(m/:/i && !m/^Logical Drive Info:/i && $cpa_mode==1){
	    @ff = split /:/;
	    siprt("tabrow");siprtt("cell",$ff[0]);
	    siprtt("cell",$ff[1]);siprt("endrow");
	  }elsif(m/^ida\// && $cpa_mode==2){
	    @ff = split / |=|:/;
	    siprt("tabrow");siprtt("cell",$ff[0]);
	    siprtt("cell",$ff[3]);siprtt("cell",$ff[5]);siprt("endrow");
	  }elsif(m/^nr_/ && $cpa_mode==2){
	    @ff = split /=/;
	    siprt("tabrow");siprtt("cell",$ff[0]);
	    siprttt("cellspan",$ff[1],2);siprt("endrow");
	  }elsif(m/^Logical Drive Info:/){
	    siprt("endtab");
	    siprtt("h2","Logical Drive Info");
	    siprtt("tabborder","lll");
	    siprt("tabrow");
	    siprtt("tabhead", "Drive");
	    siprtt("tabhead", "Blocksize");
	    siprtt("tabhead", "BlockNum");
	    siprt("endrow");
	    $cpa_mode=2;
          }else{}
	}
	close(SMART);
	siprt("endtab");
      }
    }
  }
}

sub si_gdth() {
  if(-r "/proc/scsi/gdth"){
    siprtt("h1","GDTH Vortex Raid");
    for ($i=0; $i<16; $i++) {
      if(-r "/proc/scsi/gdth/$i"){
	siprtt("h2","Controller $i");
	siprtt("tabborder","llll");
	open(GDTH, "/proc/scsi/gdth/$i");
	while(<GDTH>) {
	  if(!m/^\s+/){
	    siprt("tabrow");siprttt("headcol",$_, 4);siprt("endrow");
	  }else{
	    @ff = split /\t/,$_,4;
	    siprt("tabrow");siprtt("cell",$ff[0]);siprtt("cell",$ff[1]);
	    siprtt("cell",$ff[2]);siprtt("cell",$ff[3]);siprt("endrow");
	  }
	}
	close(GDTH);
	siprt("endtab");
      }
    }
  }
}

sub si_ips() {
  if(-r "/proc/scsi/ips"){
    siprtt("h1","IBM ServeRaid");
    for ($i=0; $i<16; $i++) {
      if(-r "/proc/scsi/ips/$i"){
	siprtt("h2","Controller $i");
	siprtt("tabborder","ll");
	open(IPS, "/proc/scsi/ips/$i");
	while(<IPS>) {
	  if((m/^\s+/)&&(!m/^$/)){
	    my ($key,$val) = split /:/;
	    siprt("tabrow");siprtt("cell",$key);siprtt("cell",$val);;siprt("endrow");
	  }
	}
	close(IPS);
	siprt("endtab");
      }
    }
  }
}

sub si_scsi() {
  my $header=0;
  if(-r "/proc/scsi/scsi"){
    open(SCSIINFO, "/proc/scsi/scsi");
    while(<SCSIINFO>) {
      if(m/^Host:\s+(.*)Channel:\s+(.*)Id:\s+(.*)Lun:\s+(.*)$/gs){
	$host=$1; $channel=$2;$id=$3;$lun=$4;
	if(!$header){
	  siprtt("h1","SCSI"); 
	  siprtt("tabborder","lllllllll");
	  siprt("tabrow");  
	  siprtt("tabhead","Host");
	  siprtt("tabhead","Channel");
	  siprtt("tabhead","Id");
	  siprtt("tabhead","Lun");
	  siprtt("tabhead","Vendor");
	  siprtt("tabhead","Model");
	  siprtt("tabhead","Revision");
	  siprtt("tabhead","Type");
	  siprtt("tabhead","SCSI Rev.");
	  siprt("endrow");
	  $header=1;
	}
      }elsif(m/^\s+Vendor:\s+(.*)\s+Model:\s+(.*)\s+Rev:\s+(.*)$/gs){
	$vendor=$1;$model=$2;$rev=$3;
      }elsif(m/^\s+Type:\s+(.*)\s+ANSI SCSI revision:\s+(.*)$/gs){
	$ttype=$1;$ansirev=$2;
        siprt("tabrow");
	siprtt("cell",$host);
	siprtt("cell",$channel);
	siprtt("cell",$id);
	siprtt("cell",$lun);
	siprtt("cell",$vendor);
	siprtt("cell",$model);
	siprtt("cell",$rev);
	siprtt("cell",$ttype);
	siprtt("cell",$ansirev);
        siprt("endrow");
      }else{}
    }
    close(SCSIINFO);
  }
  if($header){
    siprt("endtab");
  }
}

sub si_mount() {
  %fsystem  = ();
  %mountp   = ();
  %blocks   = ();
  %resblocks= ();
  %ftype    = ();
  %fbegin   = ();
  %fend     = ();
  %mountopts= ();
  @sarray   = ();
  open(MOUNT, "/bin/mount |");
  while(<MOUNT>) {
    if(m/^\/dev/g){
      @params = split /\s+/;
      $fsystem{$params[0]} = $params[4];
      $mountp{$params[0]} = $params[2];
      $mountopts{$params[0]} = $params[5];
    }
  }
  close(MOUNT);
  open(FDISK, "/sbin/fdisk -l |");
  while(<FDISK>) {
    s/\*//gs;
    if(m/^\/dev/g){
      @fparams = split /\s+/,$_, 6;
      $blocks{$fparams[0]} = $fparams[3];
      chomp($ftype{$fparams[0]} = $fparams[5]);
      $fbegin{$fparams[0]} = $fparams[1];
      $fend{$fparams[0]} = $fparams[2];
      $ftypenum{$fparams[0]} = $fparams[4];
      if($ftypenum{$fparams[0]} eq "8e"){$ftype{$fparams[0]} = "LVM-PV"}
      if($ftypenum{$fparams[0]} eq "fe"){$ftype{$fparams[0]} = "old LVM"}
    }
  }
  close(FDISK);
  open(DFK, "/bin/df -PPk |");
  while(<DFK>) {
    if(m/^\/dev/g){
      @dfkparams = split /\s+/,$_, 6;
      # $blocks{$dfkparams[0]} = $dfkparams[3];
      $dfkblocks{$dfkparams[0]}  = $dfkparams[1];
      $dfkused{$dfkparams[0]}    = $dfkparams[2];
      $dfkavail{$dfkparams[0]}   = $dfkparams[3];
      $dfkpercent{$dfkparams[0]} = $dfkparams[4];
      $dfkmountp{$dfkparams[0]}  = $dfkmountp[4];
    }
  }
  close(DFK);  
  open(LVM, "/proc/lvm |");
  while(<LVM>) {
    if(m/^LVM/g){}
    if(m/^Total/g){}
    if(m/^Global/g){}
    if(m/^VG/g){}
    if(m/^\s\sPV/g){}
    if(m/^\s\s\s\sLV/g){}
    if(m/^\/dev/g){
      #@dfkparams = split /\s+/,$_, 6;
      ## $blocks{$dfkparams[0]} = $dfkparams[3];
      #$dfkblocks{$dfkparams[0]}  = $dfkparams[1];
      #$dfkused{$dfkparams[0]}    = $dfkparams[2];
      #$dfkavail{$dfkparams[0]}   = $dfkparams[3];
      #$dfkpercent{$dfkparams[0]} = $dfkparams[4];
    }
  }
  close(LVM);  
  siprtt("h1","Partitions, Mounts, LVM");
  siprtt("tabborder","llllllllllllllll");
  @tarray = sort keys %mountp;
  push @tarray, sort keys %blocks;
  $oldtt="";
  for $tt (sort @tarray) {
    if($oldtt ne $tt){push @sarray, $tt;}
    $oldtt=$tt;
  }  
  # for $tt (sort keys %mountp) {
  siprt("tabrow");
  siprtt("tabhead","Partition");
  siprtt("tabhead","Part.-type");
  siprtt("tabhead","\#");
  siprtt("tabhead","Begin");
  siprtt("tabhead","End");
  siprtt("tabhead","Raw size");
  siprtt("tabhead","Mountpoint");
  siprtt("tabhead","Filesys.");
  siprtt("tabhead","res.");
  siprtt("tabhead","BlkSize");
  siprtt("tabhead","I.Dens.");
  siprtt("tabhead","MaxMnt");
  siprtt("tabhead","Blocks");
  siprtt("tabhead","Used");
  siprtt("tabhead","Avail.");
  siprtt("tabhead","%");
  siprt("endrow");
  open (SAVEERR, ">&STDERR");
  open (STDERR, ">/dev/null");
  for $tt (sort @sarray) {
    open(TUNE, "/sbin/tune2fs -l $tt |");
    while(<TUNE>){
      if(m/^Reserved block count:\s*(\w+)\s*$/g){$resblocks{$tt}=$1;}
      if(m/^Block size:\s*(\w+)\s*$/g){$blocksize{$tt}=$1;}
      if(m/^Inode count:\s*(\w+)\s*$/g){$inodecount{$tt}=$1;}
      if(m/^Block count:\s*(\w+)\s*$/g){$blockcount{$tt}=$1;}
      if(m/^Maximum mount count:\s*(\w+)\s*$/g){$maxmount{$tt}=$1;}
    }
    close(TUNE);
    if(($inodecount{$tt}!=0) && ($blockcount{$tt}!=0) && ($blocksize{$tt}!=0)) {
      $inodedensity{$tt}
      =(2**int(log($blockcount{$tt}/$inodecount{$tt})/log(2)+0.5))*$blocksize{$tt};
    }else{
      $inodedensity{$tt}="-";
    }
  }
  open (STDERR,  ">&SAVEERR");
  for $tt (sort @sarray) {
    siprt("tabrow");
    siprtt("cell",$tt);  
    siprtt("cell",$ftype{$tt});
    siprtt("cell",$ftypenum{$tt});
    siprtt("cell",$fbegin{$tt});
    siprtt("cell",$fend{$tt});
    siprtt("cell",$blocks{$tt});
    siprtt("cell",$mountp{$tt}); 
    siprtt("cell",$fsystem{$tt});
    siprtt("cell",$resblocks{$tt});
    siprtt("cell",$blocksize{$tt});
    siprtt("cell",$inodedensity{$tt});
    siprtt("cell",$maxmount{$tt});
    siprtt("cell",$dfkblocks{$tt});
    siprtt("cell",$dfkused{$tt});
    siprtt("cell",$dfkavail{$tt});
    siprtt("cell",$dfkpercent{$tt});
    siprt("endrow");
  }
  siprt("endtab");
  #
  # open(PART, ">sitar-$HOSTNAME.part");
  # for $tt (sort @sarray) {
  #  print PART "";
    #  $tt, $ftype{$tt}, "</td>",
    #  "<td>", $ftypenum{$tt}, "</td>",
    #  "<td>", $fbegin{$tt}, "</td>",
    #  "<td>", $fend{$tt}, "</td>",
    #  "<td>", $blocks{$tt}, "</td>",
    #  "<td>", $mountp{$tt}, "</td>", 
    #  "<td>", $fsystem{$tt}, "</td>",
    #  "<td>", $resblocks{$tt}, "</td>",
    #  "<td>", $blocksize{$tt}, "</td>",
    #  "<td>", $inodedensity{$tt}, "</td>",
    #  "<td>", $maxmount{$tt}, "</td>",
    #  "<td>", $dfkblocks{$tt}, "</td>",
    #  "<td>", $dfkused{$tt}, "</td>",
    #  "<td>", $dfkavail{$tt}, "</td>",
    #  "<td>", $dfkpercent{$tt}, "</td>",
    #  "\n</tr>\n";
  # }  
  # close(PART);
}

sub si_ifconfig() {
  my %rule = ();
  my $isbegin=1;
  open(IFCONFIG, "/sbin/ifconfig -v |");
  siprtt("h1","Networking - Interfaces");
  siprtt("verb","skipping IPv6 Options");
  siprtt("tabborder","lllllllll");
  siprt("tabrow");
  siprtt("tabhead","Device");     siprtt("tabhead","Link Encap");
  siprtt("tabhead","HW-Address"); siprtt("tabhead","IP");
  siprtt("tabhead","Broadcast");  siprtt("tabhead","Mask");
  siprtt("tabhead","Options");    siprtt("tabhead","MTU");siprtt("tabhead","Metric");
  siprt("endrow");
  while(<IFCONFIG>) {
    if(m/^\S/g){
      siprt("tabrow");
      s/^(\w+)\s+Link\sencap:(\w+)\s+((HWaddr\s(.*))|(Loopback))\s*$/$1::$2::$5$6/ix;
      my ($t1, $t2, $t3) = split /::/;
      siprtt("cell",$t1);siprtt("cell",$t2);siprtt("cell",$t3);
    } elsif(m/.*inet6.*/g) {
    } elsif(m/.*inet.*/g) {
      s/\s*inet\saddr:([\w|.]+)\s+((Bcast:([\w|.]+)\s+)|(\s+))Mask:([\w|.]+)\s*/$1::$4::$6/ix;
      my ($t1, $t2, $t3) = split /::/;
      siprtt("cell",$t1);siprtt("cell",$t2);siprtt("cell",$t3);
    }elsif(m/.*Metric.*/g) {
      s/\s*([\w+\s]*)\s+MTU:([\w|.]+)\s+Metric:([\w|.]+)\s*/$1::$2::$3/ix;
      my ($t1, $t2, $t3) = split /::/;
      siprtt("cell",$t1);siprtt("cell",$t2);siprtt("cell",$t3);
      siprt("endrow");
    }else{}
  }
  siprt("endtab");
  close(IFCONFIG);  
}

sub si_route() {
  my %rule = ();
  my $isbegin=1;
  open(ROUTE, "/sbin/route -n |");
  siprtt("h1","routing");
  siprtt("tabborder","llllllll");
  siprt("tabrow");
  siprtt("tabhead","Destination"); siprtt("tabhead","Gateway");
  siprtt("tabhead","Genmask");     siprtt("tabhead","Flags");
  siprtt("tabhead","Metric");      siprtt("tabhead","Ref");
  siprtt("tabhead","Use");         siprtt("tabhead","IFace");
  siprt("endrow");
  while(<ROUTE>) {
    if(m/^\d/){
      my ($dest,$gate,$genmask,$flags,$metric,$ref,$use,$iface) = split /\s+/;
      siprt("tabrow");
      siprtt("cell",$dest);siprtt("cell",$gate);siprtt("cell",$genmask);
      siprtt("cell",$flags);siprtt("cell",$metric);siprtt("cell",$ref);
      siprtt("cell",$use);siprtt("cell",$iface);
      siprt("endrow");
    }
  }
  siprt("endtab");
  close(ROUTE);
}

sub si_ipchains () {
  if($UNAMER gt "2.3.1"){
    siprtt("h1","IPCHAINS: Kernel-Release $UNAMER not supported, sorry :-(\n");
  }elsif($UNAMER lt "2.1.0"){
    siprtt("h1","IPCHAINS: Kernel-Release $UNAMER (ipfwadm) not supported, sorry :-(\n");
  }else{
    my  @protocols = ();
    open(PROTO, "/etc/protocols");
    while(<PROTO>) {
      if(!m/^#/){
	 m/^(\w+)\s+(\w+)\s+(\w+)\s*/g;
	 $protocols[$2]=$1;
       }
    }
    close(PROTO);
    siprtt("h1","Packet Filter");
    open(CHAIN, "/proc/net/ip_fwchains");
    $no_header = 1;
    while(<CHAIN>) {
      ($empty,
	$chainname,	$sourcedest, 	$ifname,
       	$fw_flg,	$fw_invflg,	$proto,
	$packa,$packb,	$bytea,$byteb,	$portsrc,$portdest,
	$tos,$xor, 	$redir,$fw_mark,$outsize,$target) 
      = split /\s+/;
      $sourcedest =~ m/(\w\w)(\w\w)(\w\w)(\w\w)\/(\w\w)(\w\w)(\w\w)(\w\w)->(\w\w)(\w\w)(\w\w)(\w\w)\/(\w\w)(\w\w)(\w\w)(\w\w)/g;
      $source = join "",  hex($1), ".",hex($2), ".",hex($3), ".",hex($4),
      "/", hex($5), ".",hex($6), ".",hex($7), ".",hex($8);
      $dest   = join "",  hex($9), ".",hex($10),".",hex($11),".",hex($12),
      "/", hex($13),".",hex($14),".",hex($15),".",hex($16);
      if ($no_header) {
        if ($chainname ne "") {
          siprtt("h2","Filter Rules");
          siprtt("tabborder","lllllllllllllllll");
          siprt("tabrow");
            siprtt("tabhead","Name");        siprtt("tabhead","Target");
            siprtt("tabhead","I.face");      siprtt("tabhead","Proto");
            siprtt("tabhead","Src");         siprtt("tabhead","Port");
            siprtt("tabhead","Dest");        siprtt("tabhead","Port");
            siprtt("tabhead","Flag");        siprtt("tabhead","Inv");
            siprtt("tabhead","TOS");         siprtt("tabhead","XOR");
            siprtt("tabhead","RdPort");      siprtt("tabhead","FWMark");
            # siprtt("tabhead","OutputSize");  
            # siprtt("tabhead","Packets");
            # siprtt("tabhead","Bytes");
          siprt("endrow"); 
          $no_header = 0; 
        }
      }
      @PORT = split '-', $portsrc;
      if ($PORT[0] == $PORT[1]) {$portsrc = $PORT[0];}
      @PORT = split '-', $portdest;
      siprt("tabrow");
      siprtt("cell",$chainname);  siprtt("cell",$target); siprtt("cell",$ifname);
      siprtt("cell",(($proto eq "0")?"-":$protocols[$proto]));
      siprtt("cell",$source); 	  siprtt("cell",$portsrc);siprtt("cell",$dest);    	
      siprtt("cell",$portdest);   siprtt("cell",$fw_flg); siprtt("cell",$fw_invflg); 
      siprtt("cell",$tos);   	  siprtt("cell",$xor);  
      siprtt("cell",$redir);	  siprtt("cell",$fw_mark);
      # siprtt("cell",$outsize);
      # siprtt("cell","$packa,$packb");
      # siprtt("cell","$bytea,$byteb");
      siprt("endrow");
    }
    close(CHAIN);
    if ($no_header) {
      ## siprtt("h2","No Filter Rules active");
    }else{
      siprt("endtab");
    }
    $no_header = 1;
    open(NAMES, "/proc/net/ip_fwnames");
    while(<NAMES>) {
      ($chainname, $policy, $refcount) = split /\s+/;
      if ($no_header) {
        siprtt("h2","Filter Policy");
        siprtt("tabborder","lll");
        siprt("tabrow");
        siprtt("tabhead","Name"); siprtt("tabhead","Policy");
        siprtt("tabhead","RefCount");
        siprt("endrow");
        $no_header = 0;
      }
      siprt("tabrow");
      siprtt("cell",$chainname);  siprtt("cell",$policy);
      siprtt("cell",$refcount);
      siprt("endrow");
    }
    if($no_header == 0) {
      siprt("endtab");
    }
    close(NAMES);
  } 
}

sub si_conf($$) {
  my ($filename, $comment) = @_;
  siprtt("h2",$filename);
  # print STDERR $filename, ": ", $comment, "\n";
  siprt("pre");
  if($comment eq "/**/"){
    open(CONFIG, $filename);
    my $old_recsep = $/;
    undef $/;
    $ttt =  <CONFIG>;
    $ttt =~ s#/\*.*?\*/##gs;
    $ttt =~ s#//.*##g;
    $ttt =~ s/\n\s*\n/\n/gs;
    close(CONFIG);
    siprtt("verb",$ttt);
    $/=$old_recsep;
  }else{
    open (CONFIG, "<$filename");
    while (<CONFIG>) {
      chomp();
      if(!m/^($comment)|^$/) {
         siprtt("verb","$_\n");
      }
    }
    close (CONFIG);
  }
  siprt("endpre");  
}

sub si_build_proc_description() {
  if(-r "/usr/src/linux/Documentation/proc.txt"){
    open(PROCTXT, "</usr/src/linux/Documentation/proc.txt");
  }else{
    open(PROCTXT, "<$PREFIX/share/sitar/proc.txt");
  }
  $old_slash=$/;
  undef $/;
  $_=<PROCTXT>;
  my @proc_a=split /\n\n/;
  close(PROCTXT);
  $/=$old_slash;
  for $NN (@proc_a){
     my @mypair = split /\n/, $NN, 2;
     my $newkey = $mypair[0];
     my $newval = $mypair[1];
     $proc_h{$newkey}=$newval;
  }
}

sub si_proc_sys_net () {
  siprtt("h2","/proc/sys/net");
  for $NET (qw(802 appletalk ax25 rose x25 bridge core decnet ethernet ipv4 ipv6 irda ipx net-rom token-ring unix)) {
    if((-d "/proc/sys/net/$NET")) {
      opendir(DIR,"/proc/sys/net/$NET");
      @curr_dir=readdir(DIR);
      if($#curr_dir>1) {
        siprtt("h3","/proc/sys/net/$NET");
        siprtt("tabborder","llp{.5\\textwidth}");
        open(SAVEERR, ">&STDERR");
        open(STDERR, ">/dev/null");
        for $NN (sort `/usr/bin/find /proc/sys/net/$NET/`) {
          chomp(my $value = `/bin/cat $NN`);
          if($value ne "") {
	    my $MM=$NN;
	    $MM =~ s/\/proc\/sys\/net\/$NET\///;
            $OO = $MM;
	    $OO =~ s/(\w+\/)*(\w+)$/$+/;
            chomp $OO;
	    siprt("tabrow");siprtt("cell",$MM);siprtt("cell",$value);
            siprtt("cellwrap",$proc_h{$OO});siprt("endrow");
          }
        }
        open(STDERR,  ">&SAVEERR");
        siprt("endtab");
      }
    }
  }
}

sub si_proc_sys () {
  si_build_proc_description();
  siprtt("h1","/proc/sys");
  si_proc_sys_net();
}

sub si_etc() {
 siprtt("h1","configuration");
  my @lines = ();
  open (RCCONFIG, "</etc/rc.config");
  while (<RCCONFIG>) {
    s/="no"/=no/i;
    s/="yes"/=yes/i;
    if(m/START_POSTFIX=yes/i) {
      push @lines, $_; 
      siprtt("h2","postfix (postconf -n)");
      siprt("pre");
      open (CONFIG, "/usr/sbin/postconf -n |");
      while (<CONFIG>) {
	chomp();
	siprtt("verb","$_\n");
      }
      close (CONFIG);
      siprt("endpre");  
      if(-r "/etc/aliases")    {si_conf("/etc/aliases", "\#");}
    }
    if(!m/^#|^$|""/) {
      push @lines, $_;
    }
  }
  close (RCCONFIG);
  siprtt("h2","/etc/rc.config");
  siprt("pre");
  for $ll (@lines) {
    siprtt("verb",$ll);
    # my ($key,$val) = split /=/,$ll,2;
    # siprt("tabrow");siprtt("cell",$key);siprtt("cell",$val);siprt("endrow");
  }
  siprt("endpre");
  if(-r "/etc/rc.config.d" )       {
      for $NN (`/usr/bin/find /etc/rc.config.d -name "*.config"` ) {
	chomp $NN;
	si_conf($NN, "\#");
      }
  }
  my %myfiles=();
  my @allfiles = qw (
	/etc/squid.conf
	/etc/syslog.conf
	/etc/dhcpd.conf
	/etc/httpd/httpd.conf
	/etc/openldap/slapd.conf
	/etc/inetd.conf
	/etc/xinetd.conf
	/etc/printcap
	/etc/hosts
	/etc/lilo.conf
	/etc/fstab
	/etc/inittab
	/etc/passwd
	/etc/group
	/etc/rc.firewall
	/var/spool/fax/etc/config
	/var/spool/fax/etc/config.modem
  );
  foreach (`$LS -1 $config_dir/*.include`) {
	chomp ($_);
        do "$_";
        push @allfiles, @files; 
  }
  foreach (@allfiles) {
	$myfiles{$_}=0;
  }
  foreach $mm (sort keys %myfiles) {
	if( $mm !~ /proc/) {
  		if(-r $mm)	{si_conf($mm, "\#");}
	}
  }
  #
  # Samba
  #  
  if(-r "/etc/smb.conf") {si_conf("/etc/smb.conf", ";");}
  #
  # named
  #  
  if(-r "/etc/named.conf") {
	si_conf("/etc/named.conf", "/**/");
	for $NN (`/usr/bin/find /var/named -name "*.zone"` ) {
		chomp $NN;
		si_conf($NN, ";");
	}
  	for $NN (`/usr/bin/find /var/named -name "*.db"` ) {
		chomp $NN;
		si_conf($NN, ";");
  	}
  }
  #
  # SSH/OpenSSH
  #
  if(-r "/etc/ssh/sshd_config"){
	si_conf("/etc/ssh/sshd_config", "\#");
  }elsif( "/etc/sshd_config"){
	si_conf("/etc/sshd_config", "\#");
  }
  #
  # SuSE proxy suite
  #
  if(-r "/etc/proxy-suite" )       {
      for $NN (`/usr/bin/find /etc/proxy-suite -name "*.conf"` ) {
	chomp $NN;
	si_conf($NN, "\#");
      }
  }
}

sub si_proc_config() {
  my $GZIP;
  my $comment="\#";
  if(-r "/proc/config.gz") {
    if(-r "/bin/gzip"){
      $GZIP="/bin/gzip";
    }else{
      $GZIP="/usr/bin/gzip";
    }
    siprtt("h1", "Kernel Configuration");
    siprt("multipre");
    open (CONFIG, "$GZIP -dc /proc/config.gz |");
    while (<CONFIG>) {
      chomp();
      if(!m/^($comment)|^$/) {
	siprtt("verb","$_\n");
      }
    }
    close (CONFIG);
    siprt("endmultipre");  
  }
}

sub si_installed() {
  siprtt("h1","Installed packages");
  siprtt("tabborder","llll");
  siprt("tabrow");siprtt("tabhead","Name");siprtt("tabhead","Version");
  siprtt("tabhead","Size");siprtt("tabhead","Short Description");siprt("endrow");
  my $total = 0;
  my $num   = 0;
  my @rpms;
  open (RPMS, "$RPM -qa --queryformat '%{NAME}::%{VERSION}::%{SIZE}::%{SUMMARY}\n' |");
  while (<RPMS>){push @rpms, $_;}
  close(RPMS);
  for $rpm (sort @rpms){
    my ($name,$ver,$size,$summary) = split /::/, $rpm;
    $total += $size;
    $num++;
    siprt("tabrow");siprtt("cell",$name);siprtt("cell",$ver);
    siprtt("cell",$size);siprtt("cellwrap",$summary);siprt("endrow");
  }  
  close(RPMS);
  siprt("tabrow");siprtt("tabhead","Total");siprtt("tabhead","");
  siprtt("tabhead",int($total/1024)." KBytes");
  siprtt("tabhead",$num." packets");siprt("endrow");
  siprt("endtab");
}

sub si_selection() {
  open (RPMS, "$RPM -qa --queryformat '%{NAME}::%{SIZE}\n' |");
  my $total = 0;
  my $num   = 0;
  my @rpms  = ();
  while (<RPMS>){
    my ($name,$size) = split /::/;
    push @rpms, $name;
    $total += $size;
    $num++;
  }
  close(RPMS);
  print 
    "\# SuSE-Linux Configuration : ", int($total/1024), " : ",$num,"\n",
    "Description: $HOSTNAME $now_string\n", 
    "Info:\n",
    "Ofni:\n",
    "Toinstall:\n";
  for $rr (sort @rpms) {print $rr, "\n";}
  print "Llatsniot:\n";
}

sub si_getopts($) {

}

{
	if($printhelp) {
		print "Options available:\n\t--output=<format>\tFormats: html, latex, plain\n\t--file=<file>\t\toutput filename (without: stdout)\n\t--help\t\t\tthis page\n";
	}elsif( $siprt_mode eq "html" || $siprt_mode eq "latex" ) {
		# @siprt_modes= ("html", "tex" );
		# @siprt_modes= ("html" );
		# for $mm (@siprt_modes) {
		# $siprt_mode=$mm;
		# open (SAVEOUT, ">&STDOUT");
		# open (STDOUT,  ">/tmp/sitar-$HOSTNAME.$mm");
		open (SAVEOUT, ">&STDOUT");
		if( $outfile ne "" ) {
			open (STDOUT,  ">$outfile");
		}
		siprt("header");
		si_cpu_and_memory();
		si_lsdev();
		si_pci();
		si_pnp();
		if($mm eq "tex"){
			print "\n\n\\newpage\n\n";
			print "\\begin\{sidewaystable\}\\begingroup\\footnotesize\\par\n";
		}
		si_mount();
		si_ide();
		si_scsi();
		si_gdth();
		si_ips();
		si_compaq_smart();
		si_dac960();
		if($mm eq "tex"){
			print "\\par\\endgroup\\end\{sidewaystable\}";
			print "\n\n\\newpage\n\n";
			print "\\begin\{sidewaystable\}\\begingroup\\footnotesize\\par\n";
		}
		si_ifconfig();
		si_route();
		if($mm eq "tex"){
		  	print "\\par\\endgroup\\end\{sidewaystable\}";
		  	print "\n\n\\newpage\n\n";
		  	print "\\begin\{sidewaystable\}\\begingroup\\footnotesize\\par\n";
		}
		si_ipchains ();
		if($mm eq "tex"){
		  	print "\\par\\endgroup\\end\{sidewaystable\}";
		 	print "\n\n\\newpage\n\n";
		}
		si_proc_sys();
		si_etc();
		si_installed();
		si_proc_config();
		siprt("toc");
		siprt("body");
		siprt("footer");
		open (STDOUT,  ">&SAVEOUT");
		# print "\t/tmp/sitar-$HOSTNAME.$mm\n";
		# }
		# open (SAVEOUT, ">&STDOUT");
		# open (STDOUT,  ">/tmp/sitar-$HOSTNAME.sel");
		# si_selection();
		# open (STDOUT,  ">&SAVEOUT");
		# print "\t/tmp/sitar-$HOSTNAME.sel\n";
		# open (STDOUT,  ">/tmp/sitar-$HOSTNAME.pci");
		# si_lspci();
		# open (STDOUT,  ">&SAVEOUT");
		# print "\t/tmp/sitar-$HOSTNAME.pci\n";
	}
}

