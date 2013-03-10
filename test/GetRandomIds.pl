#!/usr/bin/perl
# This script accesses the Eutilities service to compile lists of random
# IDs for each of the available databases.

use strict;
use LWP::UserAgent;

# Base URL of the eutilities service
my $eutilsBase = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';

# The number of IDs to find for each database
my $numIdsPerDb = 10;

# The list of databases
my @databases = qw(
    assembly bioproject biosample biosystems blastdbinfo books
    cdd clone dbvar epigenomics gap gapplus gcassembly gds
    gencoll gene genome genomeprj geoprofiles homologene
    journals medgen mesh ncbisearch nlmcatalog nuccore nucest
    nucgss nucleotide omia omim pcassay pccompound pcsubstance
    pmc popset probe protein proteinclusters pubmed pubmedhealth
    seqannot snp sra structure taxonomy toolkit toolkitall
    toolkitbook unigene unists
);

my $ua = LWP::UserAgent->new;
my $req;

print "<samples>\n";
foreach my $db (@databases) {
    my @samples = ();

    # Create a request
    $req = HTTP::Request->new(GET =>
      $eutilsBase . 'esearch.fcgi?db=' . $db . '&term=all[sb]');

    my $response = $ua->request($req)->content;
    #print $response . "\n\n";

    $response =~ /\<Count\>(.*?)<\/Count>/s;
    my $count = $1;
    #print "count: $count\n";

    foreach my $i (1 .. 10) {
        my $sample = int(rand($count));
        #print "  retrieving $sample\n";
        $req = HTTP::Request->new(GET =>
            'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=' . $db .
            '&term=all[sb]&retstart=' . $sample);
        $response = $ua->request($req)->content;
        #$print $response;
        $response =~ /<Id>(.*?)<\/Id>/s;
        my $id = $1;
        #print "  got id $id\n";
        push @samples, $id;
    }

    print "  <samplegroup dtd='eSummary_$db.dtd'>\n";
    foreach my $sample (@samples) {
        print "    <sample name='esummary.$db.$sample'\n" .
              "            eutil='esummary'\n" .
              "            id='$sample'>\n" .
              "      <eutils-url>esummary.fcgi?db=$db&amp;id=$sample&amp;version=2.0</eutils-url>\n" .
              "    </sample>\n";
    }
    print "  </samplegroup>\n";
}
print "</samples>\n";


