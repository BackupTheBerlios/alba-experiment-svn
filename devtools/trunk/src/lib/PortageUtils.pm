#!/usr/bin/perl

use warnings; 
use strict; 

# order of package states
my %state = ("_alpha" => 0,"_beta" => 1,"_pre" => 2,"_rc" => 3,"" => 4,"_p" => 5, "_none" => 6);


sub pkg_cmp
{
  my $p1=shift;
  my $p2=shift;
  my($r);

  $p1 =~ /^(.*)-(\d+(?:\.\d+)*)([a-z])?(?:(_alpha|_beta|_pre|_rc|_p)(\d+)?)?(?:-r(\d+))?$/;
  my($apkg,$aver,$aversuf,$astate,$astatenum,$arevnum) = ($1,$2,$3,$4,$5,$6);
  $p2 =~ /^(.*)-(\d+(?:\.\d+)*)([a-z])?(?:(_alpha|_beta|_pre|_rc|_p)(\d+)?)?(?:-r(\d+))?$/;
  my($bpkg,$bver,$bversuf,$bstate,$bstatenum,$brevnum) = ($1,$2,$3,$4,$5,$6);

  # compare package name

  $r = $apkg cmp $bpkg;
  return($r) if($r != 0);

  # compare version list

  my(@aver) = split(/\./,$aver);
  my(@bver) = split(/\./,$bver);

  my($i);
  my($c) = ($#aver <= $#bver ? $#aver : $#bver);

  for($i=0;$i<=$c;$i++)
  {
    $r = $aver[$i] <=> $bver[$i];
    return($r) if($r != 0);
  }

  $r = $#aver <=> $#bver;
  return($r) if($r != 0);

  # compare version letter (may be undefined)

  $aversuf="r0" if (!defined($aversuf));
  $bversuf="r0" if (!defined($bversuf));
  $r = $aversuf cmp $bversuf;
  return($r) if($r != 0);

  # compare states (_alpha, _beta, etc.), may be undefined
  $astate="_none" if (!(defined($astate)));
  $bstate="_none" if (!(defined($bstate)));
  $r = $state{$astate} <=> $state{$bstate};
  return($r) if($r != 0);

  # compare state number (may be undefined)

  $r = (!defined $astatenum ? -1 : $astatenum) <=> (!defined $bstatenum ? -1 : $bstatenum);
  return($r) if($r != 0);

  # compare revision (may be undefined)

  $r = (!defined $arevnum ? -1 : $arevnum) <=> (!defined $brevnum ? -1 : $brevnum);
  return $r;
};

sub pkg_sort
{
  return pkg_cmp($a,$b);
};

1

#my $p1=$ARGV[0];
#my $p2=$ARGV[1];
#my (@pkgs) = sort pkg_cmp $p1,$p2 ;
#print "@pkgs\n";
