#!/usr/bin/perl
# This script reads db-samples.txt, and automatically pulls down sample ESummary XML files from
# e-utils, as well as the DTDs.
# This won't overwrite any existing files.

# This script can also auto-generate an XML file that describes each of the samples,
# with the name esummary-samples.xml.  It will only do it if you set $genSampXml to
# a true value below, and only if the file doesn't already exist.  This is only
# intended to be done once; after that, it should be maintained separately.

use strict;

my $genSampXml = 1;
my $sampXmlFile = "esummary-samples.xml";
if (-f $sampXmlFile) { $genSampXml = 0; }

my $samples = "db-samples.txt";
my $esummaryBase = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?retmode=xml&version=2.0";
my $esummaryDtdBase = "http://www.ncbi.nlm.nih.gov/entrez/query/DTD/eSummaryDTD/";

open SAMPLES, $samples or die "Can't open $samples";
if ($genSampXml) {
    open SAMPXML, ">$sampXmlFile" or die "Can't open $sampXmlFile for writing";
}

if ($genSampXml) {
    print SAMPXML "<samples>\n" .
                  "  <samplegroup header='ESummary'>\n";
}

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
    if ($genSampXml) {
        my $esumUrlEsc = $esummaryUrl;
        $esumUrlEsc =~ s/\&/\&amp;/g;
        print SAMPXML "    <sample title='ESummary $db' status='' name='esummary.$db'>\n" .
                      "      <eutils-url>$esumUrlEsc</eutils-url>\n" .
                      "      <desc></desc>\n" .
                      "    </sample>\n";
    }
}

print SAMPXML "  </samplegroup>\n</samples>\n";
if ($genSampXml) {
    close SAMPXML;
}
close SAMPLES;