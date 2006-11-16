#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;

sub cmp_ebuild_ver($$){

	my $ebuild_ver1=shift;
	my $ebuild_ver2=shift;
	my @vers1=split(/\.|_/,$ebuild_ver1);
	my @vers2=split(/\.|_/,$ebuild_ver2);
	
	my $i=0;
	my $last=$#vers1;

	$last=$#vers2 if ($#vers2 gt $#vers1);
	print "vers1=@vers1 vers2=@vers2 last=$last\n";
	#Compares major version
	while ($i ne $last+1){ 
		print "$i: $vers1[$i] $vers2[$i]\n";
		if ((!defined($vers2[$i])) || ($vers1[$i] gt $vers2[$i])) {
			return 1;
		}
		elsif ((!defined($vers1[$1])) || ($vers1[$i] lt $vers2[$i])) {
			return 2;
		}
		$i++;
	}
	return 0;
}


########
# MAIN #
########

my $ret=cmp_ebuild_ver($ARGV[0],$ARGV[1]);
print "bigger is $ret\n";
