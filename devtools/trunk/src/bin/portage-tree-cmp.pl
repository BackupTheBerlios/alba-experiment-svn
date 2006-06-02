#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;

# This script can be used to compare two portage tree and
# finding new packages that have been added 
# Part of Alba-Experiment Solaris/Portage Project

my $debug;
my %tinfo1;
my %tinfo2;
my $OVERLAY='/opt/portage-x86-sunos/';

sub find_ebuild($$){
	my $tree=shift;
	my $info=shift;
	open (PT,"/usr/gnu/bin/find $tree -name *.ebuild |") || die "$!";

	my $i=0;
	while (<PT>){
		chomp;
		s:^$tree::;
		next if (/^$/);
		next if (/^\.+$/);
		my ($cat,$pkg,$ebuild)=split('/');
		my $ver="";
		my $rel="";
		if ($ebuild =~ /^(.*)-([0-9].*)-r([0-9].*)\.ebuild/){
			$ver=$2;
			$rel=$3;
		}
		elsif ($ebuild =~ /^(.*)-([0-9].*)\.ebuild/){
			$ver=$2;
			$rel="";
		}
		if ((defined($info->{"$cat/$pkg"}) && ($info->{"$cat/$pkg"}{version} lt $ver))
			|| (!defined($info->{"$cat/$pkg"}))){
			$info->{"$cat/$pkg"}{version}=$ver;
			$info->{"$cat/$pkg"}{release}=$rel;
		}
	}
}

sub cmp_ebuild_ver($$){

	my $ebuild_ver1=shift;
	my $ebuild_ver2=shift;
	my @vers1=split(/\.,_/,$ebuild_ver1);
	my @vers2=split(/\.,_/,$ebuild_ver2);
	print "vers1=@vers1 vers2=@vers2\n";
	
	my $i=0;
	my $size=$#vers1;
	$size=$#vers2 if ($#vers2 gt $#vers1);
	#Compares major version
	while ($i lt $size){ 
		if (!defined($vers2[$i]) || ($vers1[$i] gt $vers2[$i])) {
			return 1;
		}
		elsif ((!defined($vers1[$1])) || ($vers1[$i] lt $vers2[$i])) {
			return 2;
		};
		$i++;
	}
	return 0;
}


########
# MAIN #
########

if ($#ARGV ne 1){
	print "ERROR: Expecting two arguments, found $#ARGV\n";
	print "Usage: $0 PORTAGE_TREE1 PORTAGE_TREE2\n";
	exit 1;
}

print "Reading first tree: $ARGV[0] ...";
find_ebuild($ARGV[0],\%tinfo1);
print "done\n";
print Dumper(\%tinfo1) if $debug;
print "Reading second tree: $ARGV[0] ...";
find_ebuild($ARGV[1],\%tinfo2);
print "done\n";
print Dumper(\%tinfo2) if $debug;

foreach my $p (sort keys %tinfo1){
		my $ret=cmp_ebuild_ver($tinfo2{$p}{version},$tinfo1{$p}{version});
		print "bigger is $ret\n";
		if (defined($tinfo2{$p}) && 
			($tinfo2{$p}{version} gt $tinfo1{$p}{version})){
			print "$p-$tinfo1{$p}{version}-r$tinfo1{$p}{release} < $p-$tinfo2{$p}{version}-r$tinfo2{$p}{release}\n";
		}
}
