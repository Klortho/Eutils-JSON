#!/opt/perl-5.8.8/bin/perl

use strict;
use EutilsJson;
use Data::Dumper;

my $samples = EutilsJson::readSamples();
#print Dumper($samples);


foreach my $samplegroup (@$samples) {
    my $dtd = $samplegroup->{dtd};

    # If the DTD doesn't exist as a local file, skip this one.
    next if ! -f $dtd;
    print "--------------------------------------------------\n" .
          "Testing sample group for DTD '$dtd'\n";

    my $basename = $dtd;
    $basename =~ s/\.dtd$//;
    my $tojsonxsl = $basename . '-2json.xsl';

    my $status = system "dtd2xml2json $dtd $tojsonxsl";
    if ($status != 0) {
        print "Failed to generate $tojsonxsl; skipping.\n";
        next;
    }

    my $groupsamples = $samplegroup->{samples};
    foreach my $s (@$groupsamples) {
        print "  testing $s->{name}\n";
        my $eutilsUrl = $EutilsJson::eutilsBaseUrl . $s->{"eutils-url"};
        my $out = $s->{name} . ".xml";
        print "    fetching $eutilsUrl\n";
        $status = system "curl --silent --output $out $eutilsUrl";
    }
}

