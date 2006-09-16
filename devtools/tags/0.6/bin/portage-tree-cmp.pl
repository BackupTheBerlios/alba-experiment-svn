#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;

# This script can be used to compare two portage tree and
# finding new packages that have been added 
# Part of Alba-Experiment Solaris/Portage Project

my $debug=1;
our $tinfo1;
our $tinfo2;
my $BASE_PORTDIR=`portageq portdir`;
my $OVER_PORTDIR=`portageq portdir_overlay`;

chomp $BASE_PORTDIR;
chomp $OVER_PORTDIR;

sub find_ebuild($$){
	my $tree=shift;
	my $info=shift;
	open (PT,"/usr/gnu/bin/find $tree -name *.ebuild |") || die "$!";

	my $i=0;
	while (<PT>){
		chomp;
		print STDERR "\rProcessing \"$_\"\n";
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
	my @vers1=split(/\.|_/,$ebuild_ver1);
	my @vers2=split(/\.|_/,$ebuild_ver2);
	
	my $i=0;
	my $size=$#vers1;
	#print "vers1=@vers1 vers2=@vers2 size=$#vers1\n";
	$size=$#vers2 if ($#vers2 gt $#vers1);
	#Compares major version
	while ($i le $size){
		if (defined($vers2[$i]) && defined($vers1[$i])){
			#print "$i) $vers1[$i] gt $vers2[$i]? \n";
			if (($vers1[$i] gt $vers2[$i])) {
				return 1;
			}
			elsif (($vers1[$i] lt $vers2[$i])) {
				return 2;
			};
		}
		$i++;
	}
	return 0;
}


########
# MAIN #
########

#if ($#ARGV ne 1){
	#print "ERROR: Expecting two arguments, found $#ARGV\n";
	#my $bname=`basename $0`;
	#chomp $bname;
	#print "Usage: $bname BASE_PORTAGE_TREE1 OVERLAY_PORTAGE_TREE2\n";
	#exit 1;
#}

if ( (-f "$ENV{HOME}/.ae/tree1-data.pl") || (-f "$ENV{HOME}/.ae/tree2-data.pl") ){
	print "Tree data already saved. Remove the files from ~/.ae directory to update them\n";
	require "$ENV{HOME}/.ae/tree1-data.pl";
	require "$ENV{HOME}/.ae/tree2-data.pl";
}
else {
	print "Reading first tree: $BASE_PORTDIR ...";
	find_ebuild($BASE_PORTDIR . "/",$tinfo1);
	print "done\n";
	print "Reading second tree: $OVER_PORTDIR ...";
	find_ebuild($OVER_PORTDIR . "/",$tinfo2);
	print "done\n";

	mkdir "$ENV{HOME}/.ae";
	open (T1,'>',"$ENV{HOME}/.ae/tree1-data.pl");
	open (T2,'>',"$ENV{HOME}/.ae/tree2-data.pl");
	print T1 Data::Dumper->Dump([$tinfo1],[qw($tinfo1)]);
	print T2 Data::Dumper->Dump([$tinfo2],[qw($tinfo2)]);
	close (T1);
	close (T2);
}
print Dumper($tinfo1) if $debug;
print Dumper($tinfo2) if $debug;


foreach my $p (sort keys %{$tinfo2}){
		print "cmp_ebuild_ver($tinfo2->{$p}{version},$tinfo1->{$p}{version})\n";
		my $ret=cmp_ebuild_ver($tinfo2->{$p}{version},$tinfo1->{$p}{version});
		#print "bigger is $ret\n";
		if ($ret == 2){
			print "$p ($tinfo1->{$p}{version} > $tinfo2->{$p}{version})\n";
		}
}
