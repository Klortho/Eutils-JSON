#!/usr/bin/perl 

use strict;
use LWP::UserAgent;


my $ua = LWP::UserAgent->new;

my @databases = qw(
  pubmed
);
# protein nuccore nucleotide nucgss



my @samples;
my $req;
foreach my $db (@databases) {

    # Create a request
    $req = HTTP::Request->new(GET => 
      'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=' . $db . '&term=all[sb]');

    my $response = $ua->request($req)->content;
    print $response . "\n\n";

    $response =~ /\<Count\>(.*?)<\/Count>/s;
    my $count = $1;
    print "count: $count\n";

    foreach my $i (1 .. 2) {
        my $sample = int(rand($count));
        print "  retrieving $sample\n";
        $req = HTTP::Request->new(GET => 
            'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=' . $db . 
            '&term=all[sb]&retstart=' . $sample);
        $response = $ua->request($req)->content;
	#print $response;
        $response =~ /<Id>(.*?)<\/Id>/s;
	my $id = $1;
        print "  got id $id\n";
	push @samples, $id;
    }
    
    print "  <samplegroup dtd='eSummary_$db.dtd'>\n";
    foreach my $sample (@samples) {
        print "    <sample name='esummary.$db.$sample'\n" .
	      "            eutil='esummary'\n" .
	      "            id='$sample'>\n" .
              "    </sample>\n";
    }
    print "  </samplegroup>\n";
}

@samples;


