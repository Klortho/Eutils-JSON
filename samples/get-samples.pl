#!/usr/bin/perl
# This script reads db-samples.txt, and automatically pulls down sample ESummary XML files from
# e-utils, as well as the DTDs.
# This won't overwrite any existing files.

use strict;

my $samples = "db-samples.txt";
my $esummaryBase = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&version=2.0";
my $esummaryDtdBase = "http://www.ncbi.nlm.nih.gov/entrez/query/DTD/eSummaryDTD/";

open SAMPLES, $samples or die "Can't open $samples";

while (<SAMPLES>) {
    chomp;
    next if /^\s*#/;
    my ($db, $ids) = split;
    #print "db = $db, ids = $ids\n";

    # Get the sample XML output from ESummary
    if ($db && $ids) {
        my $xmlFile = "esummary.$db.xml";
        if (! -f $xmlFile) {
            my $esummaryUrl = $esummaryBase . "&db=$db&id=$ids";
            my $cmd = "wget -O $xmlFile " . $esummaryUrl;
            $cmd =~ s/\&/\\\&/g;
            system $cmd;
        }
    }
    # Get the ESummary DTD
    if ($db) {
        my $dtdFile = "eSummary_$db.dtd";
        if (! -f $dtdFile) {
            my $dtdUrl = $esummaryDtdBase . "eSummary_$db.dtd";
            my $cmd = "wget $dtdUrl";
            system $cmd;
        }
    }
}

close SAMPLES;