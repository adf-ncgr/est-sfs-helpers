#!/usr/bin/env perl
use strict;
use Getopt::Long;
my @ingroups;
my @outgroups;
GetOptions(
    "outgroup=s" => \@outgroups,
    "ingroup=s" => \@ingroups,
);
my @outgroup_idxes;
my @ingroup_idxes;
my %ingroups = map {$_ => 1;} @ingroups;

VCF_RECORD: while (<>) {
    next if /^##/;
    chomp;
    if (/^#CHROM/) {
        my @headers = split /\t/;
        for (my $i=9; $i < @headers; $i++) {
            if ($ingroups{$headers[$i]}) {
                push @ingroup_idxes, $i;
            }
            else {
                for (my $j=0; $j < @outgroups; $j++) {
                    if ($headers[$i] eq $outgroups[$j]) {
                        $outgroup_idxes[$j] = $i;
                    }
                }
            }
        }
        next;
    }
    my @data = split /\t/;
    my %ingroup_allele2counts;
    my %allele2idx;
    #FIXMEL assuming homozygous and diplod
    $ingroup_allele2counts{0} = 2;
    my $ref_allele = $data[3];
    #exclude non-SNPs
    ##FIXME: could be too extreme, as some SNPs could get mixed up in more complex variation
    next unless length($ref_allele) == 1;
    $allele2idx{$ref_allele} = 0;
    my @alt_alleles = split /,/, $data[4];
    for (my $i=0; $i < @alt_alleles; $i++) {
        my $alt_allele = $alt_alleles[$i];
        next VCF_RECORD unless length($alt_allele) == 1;
        $allele2idx{$alt_allele} = $i+1;
    }

    my $saw_ingroup_alt=0;
    foreach my $idx (@ingroup_idxes) {
        my $gtdata = $data[$idx];
        my ($gt) = split /:/, $gtdata; 
        my @gt = split /[\/|]/, $gt;
        foreach my $allele (@gt) {
            if ($allele =~ /^[1-9]/) {
                $saw_ingroup_alt=1;
            }
            $ingroup_allele2counts{$allele}++;
        }
    }
    next unless $saw_ingroup_alt;

    foreach my $allele ("A", "C", "G", "T") {
        if (!defined $ingroup_allele2counts{$allele2idx{$allele}}) {
            $ingroup_allele2counts{$allele2idx{$allele}} = 0;
        }
    }
    print join(",", $ingroup_allele2counts{$allele2idx{"A"}}, $ingroup_allele2counts{$allele2idx{"C"}}, $ingroup_allele2counts{$allele2idx{"G"}}, $ingroup_allele2counts{$allele2idx{"T"}});
    foreach my $outgroup_idx (@outgroup_idxes) {
        print " ";
        my %outgroup_allele2counts;
        my $gtdata = $data[$outgroup_idx];
        my ($gt) = split /:/, $gtdata; 
        my @gt = split /[\/|]/, $gt;
        #FIXME: it doesn't seem to like anything bigger than 1 for outgoups
        #foreach my $allele (@gt) {
        foreach my $allele ($gt[0]) {
            $outgroup_allele2counts{$allele}++;
        }
        foreach my $allele ("A", "C", "G", "T") {
            if (!defined $outgroup_allele2counts{$allele2idx{$allele}}) {
                $outgroup_allele2counts{$allele2idx{$allele}} = 0;
            }
        }
        print join(",", $outgroup_allele2counts{$allele2idx{"A"}}, $outgroup_allele2counts{$allele2idx{"C"}}, $outgroup_allele2counts{$allele2idx{"G"}}, $outgroup_allele2counts{$allele2idx{"T"}});
    }
    #need some way of iding the records
    print "\t$data[0]\t$data[1]";
    print "\n";
}
