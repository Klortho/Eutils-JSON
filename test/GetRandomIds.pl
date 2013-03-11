#!/usr/bin/perl
# This is a throw-away script to compile lists of random
# IDs for each of the available databases.  It writes its output to
# standard out in the form of a samples.xml file.  The samples for each
# esummary database are grouped together, since they share the same DTD.

use strict;
use LWP::UserAgent;
use EutilsJson;

# The number of IDs to find for each database
my $numIdsPerDb = 10;


my $ua = LWP::UserAgent->new;
my $req;

print "<samples>\n";
foreach my $db (@EutilsJson::dbs) {
    my @samples = ();

    # Create a request
    $req = HTTP::Request->new(GET =>
      $EutilsJson::eutilsBaseUrl . 'esearch.fcgi?db=' . $db . '&term=all[sb]');

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


