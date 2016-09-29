#!/usr/bin/perl

#########################################################################
#   Copyright 2016 by Tony Austin
#   This program CAN NOT be modified or distributed without
#   the express written permission of Tony Austin
#   contact Tony at k4ama@arrl.net
#
#   B1      Sept 20, 2016       Tony Austin
#
########################################################################
#
use strict;
use warnings;
use CGI qw(param);



my $images="http://www.k4ama.com/sfcg/images";
my $this=  "http://www.k4ama.com/sfcg/index.pl";

my $contests = "data/contests.dat";   # contest listing
my $users    = "data/users.dat";      # users name, etc
my $scores   = "data/scores.dat";     # currenty entered scores
my $standings= "data/standings.dat";  # current point summary
my $tocken  =  "data/tockens.dat";    # tocken file for login stat check
my $scores  =  "data/scores.dat";     # tocken file for login stat check

# colors
my $ybg = "#ffcc00";
my $bbg = "#6666ff";
my $dbbg= "#0042aa";
my $red = "#ce0000";


my $time = localtime;
$time =~ m/([^\s]*)(\s)*([^\s]*)(\s)*([^\s]*)(\s)*([^\s]*)(\s)([^\s]*)/ig;
my $ntime = "$7";
my $today = "$3\-$5\-$9";
$today=~ s/\s//g;
my $thisyear = "$9";
my $thismonth= "$3";
my $daynum = "$5";
my $mn=0;
my ($mnum, $sdays) = getmonth($3);

my $test = 1;

   $test    = param('tst');
my $tckn    = param('t');
my $nav     = param('n');
my $listnum = param('l');
my $eventID = param('ID');
my $title   = param('title'); # event title
my $edate   = param('edate'); # event data
my $call    = param('call');
my $pw      = param('pw');
my $name    = param('name');
my $ustat   = param('ustat');
my $email   = param('email');

my $cw      = param('cw');
my $sb      = param('sb');
my $di      = param('di');

my $count;

if ($nav =~ m/^userlogin$/i) {
     &getuser;
     exit 0;
}

if ($call =~ m/[a-z]+/ig) {&tocken_check;}

if (($nav =~ m/^ae$/i) && ($call =~ m/[a-z]+/ig)) {
 &addevent;
 exit 0;
}

if (($nav =~ m/^ce$/i) && ($call =~ m/[a-z]+/ig)) {
  my $stl = length $title;

  if ($stl <= 5)  {
       print "Location: $this?n=ae&call=$call&t=$tckn\n\n";
       exit 0;
  }

 &cleandata;
 &checkevent;
 exit 0;
}

if (($nav =~ m/^pe$/i) && ($call =~ m/[a-z]+/ig)) {
 &cleandata;
 &postevent;
 exit 0;
}

if ($nav =~ m/^p$/i) {
     &postpage;
     exit 0;
}

if ($nav =~ m/^li$/i) {
     &login;
     exit 0;
}

if ($nav =~ m/^mi$/i) {
     &myinfo;
     exit 0;
}



&page1;
exit 0;

sub addevent {

    &start;
    &head;
    &addnewevent;
    &bottom;
    &end;

    return;
} # end sub addevent

sub checkevent {

    &start;
    &head;
    &checknewevent;
    &bottom;
    &end;

    return;
} # end sub checkevent

sub postevent {

    &postdata;

    &start;
    &head;
    &addnewevent;
    &bottom;
    &end;

    return;
} # end sub checkevent

sub myinfo {

    &start;
    &head;
    &userlogindata;
    &bottom;
    &end;
    return;
} # end myinfo

sub getuser {

    my $pass = &checkuser($call, $pw);

    &start;
    &head;
    if ($pass) {
         # get tocken
         $tckn = &gettocken($call);
         # set tocken
         &loguser($call);
         &userlogindata;
    } else {
         &sorry;
    }
    &bottom;
    &end;

    return;
} # end sub get user



sub login {

    &start;
    &head;
    &userlogin;
    &bottom;
    &end;
    return;
} # end sub login

sub postpage {

    &start;
    &head;
    &post;
    &bottom;
    &end;
    return;
} # end sub postpage


sub page1 {

    &start;
    &head;
    &body;
    &bottom;
    &end;
    return;
} # end sub page 1

sub postdata {

#fabricate event label

my $label;
my $ddate;
my $elabel;
my $chars;
my $coma = 0;

$label = $title;

$label =~ s/\s//g;
$label =~ s/\"//g;

$chars = substr($label, 0, 4, "");


$ddate = $edate;
$ddate =~ s/\s//g;
$ddate =~ s/,//g;
$ddate =~ s/\"//g;


$elabel = $chars . $ddate;


open(LOG, ">>$contests") || die "cannot append contest $!";

print LOG "$elabel|$title|$edate|";
if ($cw >= 1) {
print LOG "CW";
$coma=1;
}
if (($sb >= 1) && ($cw >= 1)) {
print LOG ",SB";
} elsif (($sb >= 1) && ($cw == 0)) {
print LOG "SB";
}
if (($di >= 1) && (($cw >= 1) || ($sb >=1))) {
print LOG ",DI";
} elsif (($di >= 1) && (($cw == 0) && ($sb == 0))) {
print LOG "DI";
}

print LOG "|$cw $sb $di|\n";

close(LOG);

return;

} # sub postdata


sub update {


print "<center><br><br>\n";
print "<table width=700  cellspacing=0 cellpadding=5>\n";
print "<tr><td bgcolor=#EFEFEF>\n";

print "<div class=T12> (Sept 23, 2016) :: Working on login persistance using tockens..no joy yet, pw is sfcg...\n";
print "<div class=T12> (Sept 22, 2016) :: Working on user/member login...\n";
print "<div class=T12> (Sept 21, 2016) :: Links work for current contests, member login link page setup...\n";
print "<div class=T12> (Sept 20, 2016) :: Contest listing at left and right read from data file.\n";

print "<div class=T12> (Sept 20, 2016) ::  Converted the basic layout to a perl script.  It is currently running\n";
print "as a functional program.  Will start setting up contest, member and score files next.\n";
print "The full URL is http://www.k4ama.com/sfcg/index.pl  Test <a href=$this class=L1>link</a>\n";

print "</td></tr></table>\n";
print "</center>\n";


} # end sub update

sub cleandata {
        chomp($title);
        $title =~ s/\r//g;
        chomp($edate);
        $edate =~ s/\r//g;

} # end sub cleandata


sub checkuser {

my $pass = 0;
my $passw;
my $ucall;

open(LOG, "<$users") || die "cant read user file $!";
my @users = <LOG>;
close(LOG);

foreach my $line (@users) {
        my @pcs = split(/\|/, $line);

        $ucall= $pcs[0];
        $name = $pcs[1];
        $ustat= $pcs[2];
        $email= $pcs[3];
        $passw= $pcs[4];

        $ucall =~ s/\s//;
        $passw =~ s/\s//;
        chomp($ucall);
        chomp($passw);

        if (($call =~ m/$ucall/i) && ($pw =~ m/$passw/i)) {
        $pass = 1; +
        $call = $ucall;
        }

        if ($pass) {last;}

} # end foreach


return($pass);

} # end sub checkuser

sub end {

return;

}

sub bottom {

  print "<center>\n";
  print "<table width=1280 cellspacing=0 border=0 cellpadding=4>\n";
  print "<tr><td height=1 bgcolor=$dbbg>\n";
  print "<img scr=# height=1 width=1 align=right vspace=2>\n";
  print "</td></tr><tr><td>\n";

  if ($thisyear > 2016) {
       print "<br><br><center><div class=T11>&copy; 2016 - $thisyear Swamp Fox Contest Group</div></center>\n";
  } else {
       print "<br><br><center><div class=T11>&copy; $thisyear Swamp Fox Contest Group</div></center>\n";
  }

  print "</td></tr></table></center>\n";
  print "</center>\n";

  #&update;

  return;

} # end sub bottom


sub userlogindata {

  my $sb = 0;
  my $cw = 0;
  my $di = 0;
  my $count = 0;



  open(LOG, "<$scores") || die "cant open score file $!";
  my @score=<LOG>;
  close(LOG);

  foreach my $line (@score) {
  chomp($line);

  if ($line =~ m/^$call\|/) {
     my @pcs = split(/\|/, $line);
     $sb += $pcs[2];
     $cw += $pcs[3];
     $di += $pcs[4];
     $count++;
  } # end if

  } # end foreach


  print "<center>\n";
  print "<table width=1280 cellspacing=0 border=0 cellpadding=5><tr><td width=240 bgcolor=$ybg height=480 valign=top align=left>\n";
  print "<!-- Left Side Nav --> \n";

  print "<div class=B14>User Login</div><br> \n";

  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>EME Eclipse Party</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>7 Zone Aurora Madness</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Alaska Pre-Freeze Boogie</a><br>  \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Florida Sunburn Celebration</a><br> \n";

  &newevents;

  print "</td><td width=800 bgcolor=#FFFFFF valign=top align=left>\n";
  print "<!-- Center Data window -->\n";
  print "<a href=$this?call=$call&t=$tckn class=L2>Home Page</a><br><br><br>\n";
  print "<div class=T14>Member Information Page</div>\n";
  print "<br><br>\n";
  print "<center>\n";
  #print "<div class=B16>Post Event Scores</DIV>\n";
  print "<table width=700 bgcolor=$dbbg cellspacing=0 cellpadding=0>\n";
  print "<tr><td height=250 bgcolor=#EFEFEF valign=top align=left>\n";


  print "<table width=100% cellspacing=0 border=0 bordercolor=$dbbg cellpadding=0>\n";

  print "<tr bgcolor=$dbbg><td bgcolor=$dbbg>\n";
  print "&nbsp\;";
  print "</td><td>\n";
  print "&nbsp\;\n";
  print "</td></tr>\n";
  print "<tr><td width=50%>\n";

  print "<div class=T14>$name $call </div>\n";

  print "</td><td> &nbsp\;\n";

  print "</td></tr>\n";
  print "<tr><td width=50%>\n";

  print "<table width=100% cellspacing=0 border=0 cellpadding=3>\n";
  print "<tr bgcolor=#d1d1d1><td width=50%>\n";
  print "<div class=T12>SSB Q's</div>\n";

  print "</td><td align=left>\n";
  print "<div class=T12> $sb</div>\n";

  print "</td></tr><tr><td>\n";
  print "<div class=T12>CW Q's</div>\n";

  print "</td><td align=left>\n";
  print "<div class=T12>$cw</div>\n";

  print "</td></tr><tr bgcolor=#d1d1d><td>\n";
  print "<div class=T12>DI Q's</div>\n";

  print "</td><td align=left>\n";
  print "<div class=T12>$di</div>\n";

  print "</td></tr><tr><td>\n";
  print "<div class=T12>No. Contests\n";

  print "</td><td align=left>\n";
  print "<div class=T12>$count\n";

  print "</td></tr></table>\n";

  print "</td><td valign=top>\n";

  print "<table width=100% cellpadding=3>\n";
  print "<tr><td valign=top align=center>\n";

  print "<a href=$this?call=$call&t=$tckn&n=enc class=L1>1) Edit Name and Call</a><br><br>\n";
  print "<a href=$this?call=$call&t=$tckn&n=eem class=L1>2) Edit Email Address</a><br><br>\n";
  print "<a href=$this?call=$call&t=$tckn&n=ycl class=L1>3) Your Constest List</a><br><br>\n";

  print "</td></tr></table>\n";

  print "</td></tr></table>\n";

  print "</td></tr></table>\n";

  print "<div align=left><br><br><br><br><a href=$this?call=$call&t=$tckn class=L2>Home Page</a><br></div>\n";

  print "</td><td width=240 bgcolor=$ybg valign=top align=left>\n";
  print "<!-- Riht Side Stuff window -->\n";
  print "<div class=B14>Previous Contests</div><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>North Dakota Plain Nuts</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Hawaii Lei Low Party </a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Texas Long Horn Rustle</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>California Rumble</a><br>\n";

  &pastevents;

  print "</td></tr> <table> </center>\n";

 return;


} # end sub userlogindata


sub checknewevent {





  print "<center>\n";
  print "<table width=1280 cellspacing=0 border=0 cellpadding=5><tr><td width=240 bgcolor=$ybg height=480 valign=top align=left>\n";
  print "<!-- Left Side Nav --> \n";
  print "<div class=B14>User Login</div><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>EME Eclipse Party</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>7 Zone Aurora Madness</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Alaska Pre-Freeze Boogie</a><br>  \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Florida Sunburn Celebration</a><br> \n";

  &newevents;

  print "</td><td width=800 bgcolor=#FFFFFF valign=top align=left>\n";
  print "<!-- Center Data window -->\n";
  print "<div class=T14><a href=$this?call=$call&t=$tckn class=L2>Home Page</a> >> Verify Event</div> <br><br><br>\n";
  #print "<div class=T14>Enter A New Event</div>\n";
  #print "<br><br>\n";
  print "<center>\n";
  #print "<div class=B16>Post Event Scores</DIV>\n";
 # print "<table width=700 bgcolor=#000000 cellspacing=0 cellpadding=5><tr><td height=250 bgcolor=#EFEFEF valign=top align=left>\n";
  #print "&nbsp\;\n";

  print "<form action=$this method=post>\n";
  print "<input type=hidden name=n value=pe>\n";
  print "<input type=hidden name=t value=$tckn>\n";
  print "<input type=hidden name=call value=$call>\n";

  print "<table width=700 border=0 cellspacing=0 bgcolor=#EFEFEF cellpadding=3><tr bgcolor=$red><td colspan=2>\n";
  print "<div class=T14w> Enter A new Event - Data Confirmation</div>\n";
  print "</td></tr>\n";

  print "<tr><td colspan=0>&nbsp\;</td></tr> \n";


  print "<tr cellpadding=0><td width=350 align=right valign=top>\n";
    print "<div class=T14 valign=middel><br>Full Event Title : </div>\n";
  print "</td><td width=350 aligh=left valign=bottom>\n";
    print "<input type=text name=title size=35 value=\"$title\">\n";
  print "</td></tr>\n";

  print "</td></tr>\n";
  print "<tr><td width=350 align=right>\n";
    print "<div class=T14><br>Event Date (MMM DD, YYYY) : </div>\n";
  print "</td><td width=350 aligh=left valign=bottom>\n";
    print "<input type=text name=edate size=35 value=\"$edate\">\n";
  print "</td></tr>\n";

  print "</td></tr>\n";
  print "<tr><td width=350 align=right valign=top>\n";
    print "<div class=T14><br>Event Modes : </div>\n";
  print "</td><td width=350 aligh=left valign=bottom>\n";
  print "<table width=100% cellspacing=0 border=0><tr><td width=20% align=right>\n";

  # determine modes and print radio button accordingly

    print "<div class=T12>CW </div> \n";
    print "</td><td align=left>\n";
    if ($cw) {
       print "<div class=T12> <input type=radio name=cw size=35 value=0> No <input type=radio name=cw size=35 value=1 checked=checked> Yes </div>\n";
    } else {
       print "<div class=T12> <input type=radio name=cw size=35 value=0 checked=checked> No <input type=radio name=cw size=35 value=1> Yes </div>\n";
    }
    print "</td></tr><tr><td width=20% align=right>\n";
    print "<div class=T12>SSB </div>\n";
    print "</td><td align=left>\n";
    if ($sb) {
       print "<div class=T12> <input type=radio name=sb size=35 value=0> No <input type=radio name=sb size=35 value=1 checked=checked> Yes </div>\n";
    } else {
       print "<div class=T12> <input type=radio name=sb size=35 value=0 checked=checked> No <input type=radio name=sb size=35 value=1> Yes </div>\n";
    }
    print "</td></tr><tr><td width=20% align=right>\n";
    print "<div class=T12>Digital </div>\n";
    print "</td><td align=left>\n";
    if ($di) {
       print "<div class=T12> <input type=radio name=di size=35 value=0 checked=checked> No <input type=radio name=di size=35 value=1 checked=checked> Yes </div>\n";
    } else {
       print "<div class=T12> <input type=radio name=di size=35 value=0 checked=checked> No <input type=radio name=di size=35 value=1> Yes </div>\n";
    }
    print "</td></tr></table>\n";

  print "</td></tr>\n";

  print "<tr><td colspan=2>&nbsp\;</td></tr> \n";
  print "<tr bgcolor=#FFFFFF><td colspan=2 align=center><div class=T12>Please review and confirm your entered data. Check the event modes carefully. <br>Click confirm to submit event entry.</div></td></tr> \n";

  print "<tr bgcolor=#FFFFFF><td align=right><input type=submit value=\" Confirm \"> \n";
  print "</td><td align=left> <input type=reset value= \" Reset \"> \n";

  print "</td></tr></table>\n";

  print "<div></form>\n";

 # print "</td></tr></table>\n";

  print "<div class=T14 align=left><br><br><br><br><a href=$this?call=$call&t=$tckn class=L2>Home Page</a> >> Verify Event</div> <br></div>\n";

  print "</td><td width=240 bgcolor=$ybg valign=top align=left>\n";
  print "<!-- Riht Side Stuff window -->\n";
  print "<div class=B14>Previous Contests</div><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>North Dakota Plain Nuts</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Hawaii Lei Low Party </a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Texas Long Horn Rustle</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>California Rumble</a><br>\n";

  &pastevents;

  print "</td></tr> <table> </center>\n";

 return;


} # end sub checknewevent


sub addnewevent {



  print "<center>\n";
  print "<table width=1280 cellspacing=0 border=0 cellpadding=5><tr><td width=240 bgcolor=$ybg height=480 valign=top align=left>\n";
  print "<!-- Left Side Nav --> \n";
  print "<div class=B14>User Login</div><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>EME Eclipse Party</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>7 Zone Aurora Madness</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Alaska Pre-Freeze Boogie</a><br>  \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Florida Sunburn Celebration</a><br> \n";

  &newevents;

  print "</td><td width=800 bgcolor=#FFFFFF valign=top align=left>\n";
  print "<!-- Center Data window -->\n";
  print "<div class=T14><a href=$this?call=$call&t=$tckn class=L2>Home Page</a> >> Enter Event</div> <br><br><br>\n";
  #print "<div class=T14>Enter A New Event</div>\n";
  #print "<br><br>\n";
  print "<center>\n";
  #print "<div class=B16>Post Event Scores</DIV>\n";
 # print "<table width=700 bgcolor=#000000 cellspacing=0 cellpadding=5><tr><td height=250 bgcolor=#EFEFEF valign=top align=left>\n";
  #print "&nbsp\;\n";

  print "<form action=$this method=post>\n";
  print "<input type=hidden name=n value=ce>\n";
  print "<input type=hidden name=t value=$tckn>\n";
  print "<input type=hidden name=call value=$call>\n";

  print "<table width=700 border=0 cellspacing=0 bgcolor=#EFEFEF cellpadding=3><tr bgcolor=$dbbg><td colspan=2>\n";
  print "<div class=T14w> Enter A new Event</div>\n";
  print "</td></tr>\n";

  print "<tr><td colspan=0>&nbsp\;</td></tr> \n";


  print "<tr cellpadding=0><td width=350 align=right valign=top>\n";
    print "<div class=T14 valign=middel><br>Full Event Title : </div>\n";
  print "</td><td width=350 aligh=left valign=bottom>\n";
    print "<input type=text name=title size=35>\n";
  print "</td></tr>\n";

  print "</td></tr>\n";
  print "<tr><td width=350 align=right>\n";
    print "<div class=T14><br>Event Date (MMM DD, YYYY) : </div>\n";
  print "</td><td width=350 aligh=left valign=bottom>\n";
    print "<input type=text name=edate size=35 value=\"Dec 1, 2017\">\n";
  print "</td></tr>\n";

  print "</td></tr>\n";
  print "<tr><td width=350 align=right valign=top>\n";
    print "<div class=T14><br>Event Modes : </div>\n";
  print "</td><td width=350 aligh=left valign=bottom>\n";
  print "<table width=100% cellspacing=0 border=0><tr><td width=20% align=right>\n";

    print "<div class=T12>CW </div> \n";
    print "</td><td align=left>\n";
    print "<div class=T12> <input type=radio name=cw size=35 value=0 checked=checked> No <input type=radio name=cw size=35 value=1> Yes </div>\n";
    print "</td></tr><tr><td width=20% align=right>\n";
    print "<div class=T12>SSB </div>\n";
    print "</td><td align=left>\n";
    print "<div class=T12> <input type=radio name=sb size=35 value=0 checked=checked> No <input type=radio name=sb size=35 value=1> Yes </div>\n";
    print "</td></tr><tr><td width=20% align=right>\n";
    print "<div class=T12>Digital </div>\n";
    print "</td><td align=left>\n";
    print "<div class=T12> <input type=radio name=di size=35 value=0 checked=checked> No <input type=radio name=di size=35 value=1> Yes </div>\n";
    print "</td></tr></table>\n";

  print "</td></tr>\n";

  print "<tr><td colspan=2>&nbsp\;</td></tr> \n";
  print "<tr bgcolor=#FFFFFF><td colspan=2>&nbsp\;</td></tr> \n";

  print "<tr bgcolor=#FFFFFF><td align=right><input type=submit value=\" Submit \"> \n";
  print "</td><td align=left> <input type=reset value= \" Reset \"> \n";

  print "</td></tr></table>\n";

  print "<div></form>\n";

 # print "</td></tr></table>\n";

  print "<div class=T14 align=left><br><br><br><br><a href=$this?call=$call&t=$tckn class=L2>Home Page</a> >> Enter Event</div> <br></div>\n";

  print "</td><td width=240 bgcolor=$ybg valign=top align=left>\n";
  print "<!-- Riht Side Stuff window -->\n";
  print "<div class=B14>Previous Contests</div><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>North Dakota Plain Nuts</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Hawaii Lei Low Party </a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Texas Long Horn Rustle</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>California Rumble</a><br>\n";

  &pastevents;

  print "</td></tr> <table> </center>\n";

 return;


} # end sub addnewevent


sub userlogin {

  print "<center>\n";
  print "<table width=1280 cellspacing=0 border=0 cellpadding=5><tr><td width=240 bgcolor=$ybg height=480 valign=top align=left>\n";
  print "<!-- Left Side Nav --> \n";
  print "<div class=B14>User Login</div><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>EME Eclipse Party</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>7 Zone Aurora Madness</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Alaska Pre-Freeze Boogie</a><br>  \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Florida Sunburn Celebration</a><br> \n";

  &newevents;

  print "</td><td width=800 bgcolor=#FFFFFF valign=top align=left>\n";
  print "<!-- Center Data window -->\n";
  print "<a href=$this?call=$call&t=$tckn class=L2>Home Page</a><br><br><br>\n";
  print "<div class=T14>Member Login Page</div>\n";
  print "<br><br>\n";
  print "<center>\n";
  #print "<div class=B16>Post Event Scores</DIV>\n";
  print "<table width=700 bgcolor=#000000 cellspacing=0 cellpadding=5><tr><td height=250 bgcolor=#EFEFEF valign=top align=left>\n";
  #print "&nbsp\;\n";

  print "<form action=$this method=post>\n";
  print "<input type=hidden name=n value=userlogin>\n";
  print "<div class=T14><br>Enter Your Call : <input type=text name=call width=28>\n";
  print "</div>\n";
  print "<div class=T14>Enter Password: <input type=password name=pw width=32>\n";
  print "<br><br>&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;\n";
  print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;\n";
  print "&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;&nbsp\;<input type=submit value=Submit> <input type=reset value=Reset>\n";
  print "<div></form>\n";

  print "</td></tr></table>\n";

  print "<div align=left><br><br><br><br><a href=$this?call=$call&t=$tckn class=L2>Home Page</a><br></div>\n";

  print "</td><td width=240 bgcolor=$ybg valign=top align=left>\n";
  print "<!-- Riht Side Stuff window -->\n";
  print "<div class=B14>Previous Contests</div><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>North Dakota Plain Nuts</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Hawaii Lei Low Party </a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Texas Long Horn Rustle</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>California Rumble</a><br>\n";

  &pastevents;

  print "</td></tr> <table> </center>\n";

 return;


} # end sub userlogin

sub post {

  my $ID;
  my $ET;
  my $ED;
  my $EM;

  open (LOG, "<$contests") || die "cant read contests $!";
  my @contests = <LOG>;
  close(LOG);

  foreach my $line (@contests) {
  chomp($line);

  if ($line =~ m/^$eventID\|/i) {
       my @parts = split( /\|/, $line);
       $ID = $parts[0];      # event ID
       $ET = $parts[1];      # event Title
       $ED = $parts[2];      # event Date
       $EM = $parts[3];      # event Modes

  } # end if
  }  # end foreach

  my @modes = split(/,/, $EM);

  print "<center>\n";
  print "<table width=1280 cellspacing=0 border=0 cellpadding=5><tr><td width=240 bgcolor=$ybg height=480 valign=top align=left>\n";
  print "<!-- Left Side Nav --> \n";
  print "<div class=B14>Current Contests</div><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>EME Eclipse Party</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>7 Zone Aurora Madness</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Alaska Pre-Freeze Boogie</a><br>  \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Florida Sunburn Celebration</a><br> \n";

  &newevents;

  print "</td><td width=800 bgcolor=#FFFFFF valign=top align=left>\n";
  print "<!-- Center Data window -->\n";
  print "<a href=$this?call=$call&t=$tckn class=L2>Home Page</a><br><br><br>\n";
  print "<div class=B14>Post Event Scores :: $ET ($ED)</div>\n";
  print "<br><div class=T14>Modes this event: \n";
  foreach my $item (@modes) {
          print "$item \n";
  }
  print "<br><br>\n";
  print "<center>\n";
  #print "<div class=B16>Post Event Scores</DIV>\n";
  print "<table width=700 bgcolor=#000000 cellspacing=0 cellpadding=5><tr><td height=250 bgcolor=#EFEFEF valign=top align=left>\n";
  print "<div class=T14>Post data/Q's here&nbsp\;\n";

  print "</td></tr></table>\n";

  print "<div align=left><br><br><br><br><a href=$this?call=$call&t=$tckn class=L2>Home Page</a><br></div>\n";

  print "</td><td width=240 bgcolor=$ybg valign=top align=left>\n";
  print "<!-- Riht Side Stuff window -->\n";
  print "<div class=B14>Previous Contests</div><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>North Dakota Plain Nuts</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Hawaii Lei Low Party </a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Texas Long Horn Rustle</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>California Rumble</a><br>\n";

  &pastevents;

  print "</td></tr> <table> </center>\n";

 return;


} # end sub postpage


sub body {

  print "<center>\n";
  print "<table width=1280 cellspacing=0 border=0 cellpadding=5><tr><td width=240 bgcolor=$ybg height=480 valign=top align=left>\n";
  print "<!-- Left Side Nav --> \n";
  print "<div class=B14>Current Contests</div><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>EME Eclipse Party</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>7 Zone Aurora Madness</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Alaska Pre-Freeze Boogie</a><br>  \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Florida Sunburn Celebration</a><br> \n";

  &newevents;



  print<<"-temp1-";

  </td><td width=800 bgcolor=#FFFFFF valign=top align=left>
  <!-- Center Data window -->
  <div class=B14>Current Leaderboard</div>
  <br>
  <center>
  <div class=B16>OVERALL STANDINGS</DIV>
  <table width=700 bgcolor=#000000 cellspacing=0 cellpadding=1><tr><td>

  <table width=100% border=0 cellspacing=0 bgcolor=#FFFFFF>
  <tr BGCOLOR=#000000>
  <td><div class=B12>&nbsp;</div></td>
  <td align=left><div class=W12b>CALL</div></td>
  <td align=center><div class=W12>CW QSO'S</div></td>
  <td align=center><div class=W12>SSB QSO'S</div></td>
  <td align=center><div class=W12>DIGITAL QSO'S</div></td>
  <td align=center><div class=W12>TOTAL QSO'S</div></td>
  </tr>
  <tr>
  <td><div class=B12>1)</div></td>
  <td align=left><div class=B12>K4NVB</div></td>
  <td align=center><div class=T12>200</div></td>
  <td align=center><div class=T12>300</div></td>
  <td align=center><div class=T12>200</div></td>
  <td align=center><div class=T12>700</div></td>
  </tr>
  <tr>
  <td><div class=B12>2)</div></td>
  <td align=left><div class=B12>K4ER</div></td>
  <td align=center><div class=T12>250</div></td>
  <td align=center><div class=T12>350</div></td>
  <td align=center><div class=T12>0</div></td>
  <td align=center><div class=T12>600</div></td>
  </tr>
  <tr>
  <td><div class=B12>3)</div></td>
  <td align=left><div class=B12>K1RR</div></td>
  <td align=center><div class=T12>200</div></td>
  <td align=center><div class=T12>300</div></td>
  <td align=center><div class=T12>50</div></td>
  <td align=center><div class=T12>550</div></td>
  </tr>
  <tr>
  <td><div class=B12>4)</div></td>
  <td align=left><div class=B12>K2BB</div></td>
  <td align=center><div class=T12>200</div></td>
  <td align=center><div class=T12>100</div></td>
  <td align=center><div class=T12>100</div></td>
  <td align=center><div class=T12>400</div></td>
  </tr>
  <tr>
  <td><div class=B12>5)</div></td>
  <td align=left><div class=B12>K1KK</div></td>
  <td align=center><div class=T12>100</div></td>
  <td align=center><div class=T12>200</div></td>
  <td align=center><div class=T12>50</div></td>
  <td align=center><div class=T12>350</div></td>
  </tr>
  </table>
  </td></tr></table>
  <br><BR><BR>
   <div class=B16>INDIVIDUAL MODE STANDINGS</DIV>
  <table width=700 bgcolor=#000000 cellspacing=0 cellpadding=1>
  <tr><td width=33%>

  <table width=100% border=0 cellspacing=0 bgcolor=#FFFFFF>
  <tr BGCOLOR=#000000>
  <td><div class=B12>&nbsp;</div></td>
  <td align=left><div class=W12b>CALL</div></td>
  <td align=center><div class=W12>SSB QSO'S</div></td>
  </tr>
  <tr>
  <td><div class=B12>1)</div></td>
  <td align=left><div class=B12>K4NVB</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>2)</div></td>
  <td align=left><div class=B12>K4ER</div></td>
  <td align=center><div class=T12>250</div></td>
  </tr>
  <tr>
  <td><div class=B12>3)</div></td>
  <td align=left><div class=B12>K1RR</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>4)</div></td>
  <td align=left><div class=B12>K2BB</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>5)</div></td>
  <td align=left><div class=B12>K1KK</div></td>
  <td align=center><div class=T12>100</div></td>
  </tr>
  </table>

  </td><td width=33%>

  <table width=100% border=0 cellspacing=0 bgcolor=#FFFFFF>
  <tr BGCOLOR=#000000>
  <td><div class=B12>&nbsp;</div></td>
  <td align=left><div class=W12b>CALL</div></td>
  <td align=center><div class=W12>DIGI QSO'S</div></td>
  </tr>
  <tr>
  <td><div class=B12>1)</div></td>
  <td align=left><div class=B12>K4NVB</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>2)</div></td>
  <td align=left><div class=B12>K4ER</div></td>
  <td align=center><div class=T12>250</div></td>
  </tr>
  <tr>
  <td><div class=B12>3)</div></td>
  <td align=left><div class=B12>K1RR</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>4)</div></td>
  <td align=left><div class=B12>K2BB</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>5)</div></td>
  <td align=left><div class=B12>K1KK</div></td>
  <td align=center><div class=T12>100</div></td>
  </tr>
  </table>


  </td><td width=33%>

  <table width=100% border=0 cellspacing=0 bgcolor=#FFFFFF>
  <tr BGCOLOR=#000000>
  <td><div class=B12>&nbsp;</div></td>
  <td align=left><div class=W12b>CALL</div></td>
  <td align=center><div class=W12>CW QSO'S</div></td>
  </tr>
  <tr>
  <td><div class=B12>1)</div></td>
  <td align=left><div class=B12>K4NVB</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>2)</div></td>
  <td align=left><div class=B12>K4ER</div></td>
  <td align=center><div class=T12>250</div></td>
  </tr>
  <tr>
  <td><div class=B12>3)</div></td>
  <td align=left><div class=B12>K1RR</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>4)</div></td>
  <td align=left><div class=B12>K2BB</div></td>
  <td align=center><div class=T12>200</div></td>
  </tr>
  <tr>
  <td><div class=B12>5)</div></td>
  <td align=left><div class=B12>K1KK</div></td>
  <td align=center><div class=T12>100</div></td>
  </tr>
  </table>

  </td></tr></table>

-temp1-


  print "</td><td width=240 bgcolor=$ybg valign=top align=left>\n";
  print "<!-- Riht Side Stuff window -->\n";
  print "<div class=B14>Previous Contests</div><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>North Dakota Plain Nuts</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Hawaii Lei Low Party </a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Texas Long Horn Rustle</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>California Rumble</a><br>\n";

  &pastevents;



  print "</td></tr> <table> </center>\n";

 return;

} # end sub body

sub newevents {

  my $linknum=0;

  open (LOG, "<$contests") || die "cant read contests $!";
  my @contests = <LOG>;
  close(LOG);

  foreach my $line (@contests) {
  chomp($line);
  my @parts = split( /\|/, $line);
  $linknum++;
  print "&nbsp;&nbsp;&nbsp; <a href=$this?n=p&l=$linknum&ID=$parts[0]&call=$call&t=$tckn class=L1>$parts[1]</a><br> \n";

  }

  if ($call) {
  print "<br><br><a href=$this?n=ae&call=$call&t=$tckn class=L1>Add New Event</a>\n";
  }

} # end sub newevents

sub pastevents {

  my $linknum=0;

  open (LOG, "<$contests") || die "cant read contests $!";
  my @contests = <LOG>;
  close(LOG);

  foreach my $line (@contests) {
  chomp($line);
  my @parts = split( /\|/, $line);
  $linknum++;
  print "&nbsp;&nbsp;&nbsp; <a href=$this?n=pe&l=$linknum&ID=$parts[0]&call=$call&t=$tckn class=L1>$parts[1]</a><br> \n";

  }


} # end sub pastevents


sub head {

  print "<body leftmargin=0 topmargin=0 rightmargin=0 marginheight=0 marginwidth=0><center>\n";
  print "<!-- 1 -->\n";
  print "<table width=1280 border=0 bordercolor=#FFFFFF cellpadding=2 cellspacing=0>\n";
  print "<tr><td colspan=3 bgcolor=#FFFFFF align=center valign=top height=60>\n";

  print "<!-- 2-->\n";
  print "<table width=100% cellspacing=0 cellpadding=2 border=0><tr bgcolor=#FFFFFF><td width=20% align=center>\n";
  print "<img src=$images/sfcg.jpg height=100 border=0>  </td><td align=center valign=middle>\n";
  print "<div class=B20>SWAMP FOX CONTEST GROUP<BR><i>SFOTA</i> CURRENT POINT STANDINGS</DIV>\n";
  print "<br><div class=T16>$today</div>\n";
  print "</td><td width=20% align=right valign=bottom><div class=B14>\n";

  if ($call) {

        print "<a href=$this?n=mi&t=$tckn&call=$call class=L2>My Info</a> / <a href=$this class=L2>Log Out </a>&nbsp\;&nbsp\; </div>\n";

  } else {

       print "<a href=$this?n=li class=L2>Member Login  </a>&nbsp\;&nbsp\; </div>\n";

  }

  print "</td></tr></table>\n";
  print "<!-- end 2--> \n";
  print "</td></tr><tr><td colspan=3 height=1 bgcolor=$dbbg>\n";
  print "<img scr=# height=1 width=1 align=right vspace=2>\n";
  print "</td></tr></table>\n";
  print "<!-- end 1--></center>\n";

  return;
} # end sub head


sub start {

print "Content-type: text/html\n\n";
print "<!DOCTYPE HTML PUBLIC \"-\/\/W3C\/\/DTD HTML 4.01\/\/EN\">\n";


# start body print
  print<<"-body-";



  <head>
    <meta charset="utf-8">
    <meta name="description" content="">
    <meta name="keywords" content="">
    <title></title>

<script LANGUAGE="Javascript">
 <!--
if (parent.location.href != window.location.href) parent.location.href = window.location.href;
function openWin(URL)
{aWindow=window.open(URL,"thewindow","width=200,height=225,left=600,top=300,alwaysRaised=yes")}
function openWinm(URL)
{aWindow=window.open(URL,"thewindow","width=410,height=400,left=200,top=100")}
function openWing(URL)
{aWindow=window.open(URL,"thewindow","width=700,height=720,left=200,top=100")}
function openWin1(URL)
{aWindow=window.open(URL,"thewindow","width=1024,height=768,left=0,top=0,toolbar=yes,status=yes,menubar=yes,scrollbars=yes,resizable=yes")}
function openWin2(URL)
{aWindow=window.open(URL,"thewindow","width=1366,height=768,left=0,top=0,toolbar=yes,status=yes,menubar=yes,scrollbars=yes,resizable=yes")}
// -->
</script>


<style type=text/css>
<!--
body { color:#000000; background-color:#FFFFFF; }
a { color:#0000FF; }
img { border-style: none; }
a:visited { color:#800080; }
a:hover { color:#008000; }
a:active { color:#FF0000; }
DIV.T10{font-family: Arial, Verdana; font-size: 10px; color:#000000; font-weight: 600;}
DIV.T11{font-family: Arial, Verdana; font-size: 11px; color:#000000; font-weight: 600;}
DIV.T11r{font-family: Arial, Verdana; font-size: 11px; color:#ce0000; font-weight: 200;}
DIV.T12{font-family: Arial, Verdana; font-size: 12px; color:#000000; font-weight: 400;}
DIV.T13{font-family: Arial, Verdana; font-size: 13px; color:#000000; font-weight: 400;}
DIV.T14{font-family: Arial, Verdana; font-size: 14px; color:#000000; font-weight: 900;}
DIV.T14w{font-family: Arial, Verdana; font-size: 14px; color:#FFFFFF; font-weight: 900;}
DIV.T14r{font-family: Arial, Verdana; font-size: 14px; color:#000000; font-weight: 500;}
DIV.T16{font-family: Arial, Verdana; font-size: 16px; color:#000000; font-weight: 900;}
DIV.T18{font-family: Arial, Verdana; font-size: 16px; color:#000000; font-weight: 900;}
DIV.R12{font-family: Arial, Verdana; font-size: 12px; color:#C9170B; font-weight: 600;}
DIV.R13{font-family: Arial, Verdana; font-size: 13px; color:#C9170B; font-weight: 600;}
DIV.R14{font-family: Arial, Verdana; font-size: 14px; color:#C9170B; font-weight: 600;}
DIV.W12{font-family: Arial, Verdana; font-size: 12px; color:#FFFFFF; font-weight: 600;}
DIV.W12b{font-family: Arial, Verdana; font-size: 12px; color:#FFFFFF; font-weight: 900;}
DIV.W14{font-family: Arial, Verdana; font-size: 14px; color:#FFFFFF; font-weight: 600;}
DIV.W16{font-family: Arial, Verdana; font-size: 16px; color:#FFFFFF; font-weight: 600;}
DIV.W18{font-family: Arial, Verdana; font-size: 18px; color:#FFFFFF; font-weight: 600;}
DIV.W20{font-family: Arial, Verdana; font-size: 20px; color:#FFFFFF; font-weight: 600;}
DIV.W30{font-family: Arial, Verdana; font-size: 30px; color:#FFFFFF; font-weight: 600;}
DIV.B11{font-family: Arial, Verdana; font-size: 11px; color:#000000; font-weight: 600;}
DIV.B12{font-family: Arial, Verdana; font-size: 12px; color:#000000; font-weight: 600;}
DIV.B13{font-family: Arial, Verdana; font-size: 13px; color:#000000; font-weight: 600;}
DIV.B14{font-family: Arial, Verdana; font-size: 14px; color:#000000; font-weight: 600;}
DIV.B16{font-family: Arial, Verdana; font-size: 16px; color:#000000; font-weight: 600;}
DIV.B20{font-family: Arial, Verdana; font-size: 20px; color:#000000; font-weight: 600;}
DIV.BNH14{font-family: Arial, Verdana; font-size: 14px; color:#FFFFFF; font-weight: 600;}
DIV.BFB{font-family: Arial, Verdana; font-size: 13px; color:#000000;}
A.L1:link {font-family: Arial, Verdana; font-size: 12px; text-decoration: none; color:#000000; font-weight: 600;}
A.L1:visited {font-family: Arial, Verdana; font-size: 12px; text-decoration: none; color:#000000; font-weight: 600;}
A.L1:hover{font-family: Arial, Verdana; font-size: 12px; color:#ce0000; font-weight: 600;}
A.L1A:link {font-family: Arial, Verdana; font-size: 14px; text-decoration: none; color:#FFFFFF; font-weight: 600;}
A.L1A:visited {font-family: Arial, Verdana; font-size: 14px; text-decoration: none; color:#FFFFFF; font-weight: 600;}
A.L1A:hover{font-family: Arial, Verdana; font-size: 14px; color:#000000; font-weight: 600;}
A.L2:link {font-family: Arial, Verdana; font-size: 14px; text-decoration: none; color:#000000; font-weight: 600;}
A.L2:visited {font-family: Arial, Verdana; font-size: 14px; text-decoration: none; color:#000000; font-weight: 600;}
A.L2:hover{font-family: Arial, Verdana; font-size: 14px; color:#ce0000; font-weight: 600;}
A.L3:link {font-family: Arial, Verdana; font-size: 14px; text-decoration: none; color:#000000; font-weight: 600;}
A.L3:visited {font-family: Arial, Verdana; font-size: 14px; text-decoration: none; color:#000000; font-weight: 600;}
A.L3:hover{font-family: Arial, Verdana; font-size: 14px; color:#ce0000; font-weight: 600;}
A.L4:link {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#FFFFFF; font-weight: 600;}
A.L4:visited {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#FFFFFF; font-weight: 600;}
A.L4:hover{font-family: Arial, Verdana; font-size: 11px; color:#ce0000; font-weight: 600;}
A.L5:link {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#000000; font-weight: 600;}
A.L5:visited {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#000000; font-weight: 600;}
A.L5:hover{font-family: Arial, Verdana; font-size: 11px; color:#FFFFFF; font-weight: 600;}
A.L5a:link {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#000000; font-weight: 600;}
A.L5a:visited {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#000000; font-weight: 600;}
A.L5a:hover{font-family: Arial, Verdana; font-size: 11px; color:#ce0000; font-weight: 600;}
A.L6:link {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#000000; font-weight: 600;}
A.L6:visited {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#000000; font-weight: 600;}
A.L6:hover{font-family: Arial, Verdana; font-size: 11px; color:#ce0000; font-weight: 600;}
A.L7:link {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#000000; font-weight: 600;}
A.L7:visited {font-family: Arial, Verdana; font-size: 11px; text-decoration: none; color:#000000; font-weight: 600;}
A.L7:hover{font-family: Arial, Verdana; font-size: 11px; color:#ce0000; font-weight: 600;}
-->
  </style><!--[if IE]> <script src=http://html5shim.googlecode.com/svn/trunk/html5.js></script> <![endif]-->

    <!--[if IE]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->
  </head>

-body-
# end of body print
 return;
} # end sub start


sub sorry {

  print "<center>\n";
  print "<table width=1280 cellspacing=0 border=0 cellpadding=5><tr><td width=240 bgcolor=$ybg height=480 valign=top align=left>\n";
  print "<!-- Left Side Nav --> \n";
  print "<div class=B14>User Login</div><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>EME Eclipse Party</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>7 Zone Aurora Madness</a><br> \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Alaska Pre-Freeze Boogie</a><br>  \n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Florida Sunburn Celebration</a><br> \n";

  &newevents;

  print "</td><td width=800 bgcolor=#FFFFFF valign=top align=left>\n";
  print "<!-- Center Data window -->\n";
  print "<a href=$this?call=$call&t=$tckn class=L2>Home Page</a><br><br><br>\n";
  print "<div class=T14>Lo sentimos brote</div>\n";
  print "<br><br>\n";
  print "<center>\n";
  #print "<div class=B16>Post Event Scores</DIV>\n";
  print "<table width=700 bgcolor=#000000 cellspacing=0 cellpadding=5><tr><td height=250 bgcolor=$ybg valign=top align=left>\n";
  #print "&nbsp\;\n";

  print "<div class=T12>Not Found :: $count</div>\n";

  print "</td></tr></table>\n";

  print "<div align=left><br><br><br><br><a href=$this?call=$call&t=$tckn class=L2>Home Page</a><br></div>\n";

  print "</td><td width=240 bgcolor=$ybg valign=top align=left>\n";
  print "<!-- Riht Side Stuff window -->\n";
  print "<div class=B14>Previous Contests</div><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>North Dakota Plain Nuts</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Hawaii Lei Low Party </a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>Texas Long Horn Rustle</a><br>\n";
  #print "&nbsp;&nbsp;&nbsp; <a href=# class=L1>California Rumble</a><br>\n";

  &pastevents;

  print "</td></tr> <table> </center>\n";

 return;

} # end sorry

sub loguser {

open(LOG, ">>$tocken") || die "cant open token file $!";
print LOG "$tckn|$call|$today\n";
close(LOG);

} # end sub log user

sub gettocken {

my @chars = ("A".."D", "a".."d", "0".."9");
my $string;
$string .= $chars[rand @chars] for 1..6;

return($string);
} # end sub gettocken

sub tocken_check {

my @pass = "0,0,0,0";
my $user_num;
my $tocken_month;
my $tocken_day;
my $tocken_year;

open(LOG, "<$tocken") || die "cant read tockens $!";
my @tockens=<LOG>;
close(LOG);

foreach my $line (@tockens) {

if ($line =~ m/^$tckn\|/) {
chomp($line);
my @parts = split(/\|/, $line);
$user_num = $parts[1];
my $tocken_date = $parts[2];

my @dateparts = split(/-/, $tocken_date);
$tocken_month = $dateparts[0];
$tocken_day = $dateparts[1];
$tocken_year= $dateparts[2];
last;
} # end if
} # end foreach

if ($user_num =~ m/^$call$/) {
$pass[0] = 1;
} # end if $user_num

if ($tocken_month =~ m/$thismonth/) {
$pass[1] = 1;
}

if ($tocken_day == $daynum) {
$pass[2] = 1;
} # end if $tocken_day

if ($tocken_year == $thisyear) {
$pass[3] = 1;
} # end if $tocken_year

# clean up tocken file

open(LOG, ">$tocken") || die "cant write to tockens $!";
foreach my $line (@tockens) {
chomp($line);
if ($line =~ m/$thismonth/ig) {
     print LOG "$line\n";
} # end if
} # end foreach
close(LOG);

# check if it all passed

if (($pass[0] == 1) && ($pass[1] == 1) && ($pass[2] == 1) && ($pass[3] == 1)) {
  return;
} else {
  print "Location:$this\n\n";
}
} # end sub tocken_check

sub getmonth {
my $month = $_[0];
my $mn;
my $dn;
if ($month =~ m/jan/i) {
$mn = 1;
$dn = 31;
} elsif ($month =~ m/feb/i) {
$mn = 2;
$dn = 28;
} elsif ($month =~ m/mar/i) {
$mn = 3;
$dn = 31;
} elsif ($month =~ m/apr/i) {
$mn = 4;
$dn = 30;
} elsif ($month =~ m/may/i) {
$mn = 5;
$dn = 31;
} elsif ($month =~ m/jun/i) {
$mn = 6;
$dn = 30;
} elsif ($month =~ m/jul/i) {
$mn = 7;
$dn = 31;
} elsif ($month =~ m/aug/i) {
$mn = 8;
$dn = 31;
} elsif ($month =~ m/sep/i) {
$mn = 9;
$dn = 31;
} elsif ($month =~ m/oct/i) {
$mn = 10;
$dn = 30;
} elsif ($month =~ m/nov/i) {
$mn = 11;
$dn = 30;
} elsif ($month =~ m/dec/i) {
$mn = 12;
$dn = 31;
}
return ($mn, $dn);
} # end sub get month



exit;