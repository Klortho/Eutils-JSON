#!/usr/bin/perl
# This script reads db-samples.txt, and automatically pulls down sample ESummary XML files from
# e-utils, as well as the DTDs.
# This won't overwrite any existing files.

use strict;

my $samples = "db-samples.txt";
my $sampxml = "summary-samples.xml";
my $esummaryBase = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&version=2.0";
my $esummaryDtdBase = "http://www.ncbi.nlm.nih.gov/entrez/query/DTD/eSummaryDTD/";

open SAMPLES, $samples or die "Can't open $samples";
open SAMPXML, ">$sampxml" or die "Can't open $sampxml for writing";

print SAMPXML "<samples>\n" .
              "  <samplegroup header='ESummary'>\n";


while (my $line = <SAMPLES>) {
    chomp $line;
    $line =~ s/^\s+(.*?)\s+$/$1/;
    next if (!$line || $line =~ /^#/);
    my ($db, $ids, $desc) = split(/\s+/, $line, 3);
    #print "db = $db, ids = $ids, desc = '$desc'\n";
    my $esummaryUrl = "";

    # Get the sample XML output from ESummary
    if ($db && $ids) {
        my $xmlFile = "esummary.$db.xml";
        $esummaryUrl = $esummaryBase . "&db=$db&id=$ids";
        if (! -f $xmlFile) {
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

    # Write a record to the samples xml file
    my $esumUrlEsc = $esummaryUrl;
    $esumUrlEsc =~ s/\&/\&amp;/g;
    print SAMPXML "    <sample title='ESummary $db' status='' name='esummary.$db'>\n" .
                  "      <eutils-url>$esumUrlEsc</eutils-url>\n" .
                  "      <desc></desc>\n" .
                  "    </sample>\n";
}

print SAMPXML "  </samplegroup>\n</samples>\n";
close SAMPXML;
close SAMPLES;