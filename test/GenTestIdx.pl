#!/opt/perl-5.8.8/bin/perl

use strict;
use EutilsJson;
use Data::Dumper;

my @idxDbs = qw(
    assembly bioproject biosample biosystems blastdbinfo
    blastdbinfo_internal cdd dbvar entrezfilters epigenomics
    gap gapplus gcassembly gencoll genetests genome genomeprj
    gtr homologene inhouseprj journals ncbisearch omia omim
    orgtrack pcassay probe pubmedhealth snp sra structure toolkit
    toolkitall toolkitinternal toolkitwiki unigene unists virus
);


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

        # Fetch the XML for this eutilities sample URL
        my $eutilsUrl = $EutilsJson::eutilsBaseUrl . $s->{"eutils-url"};
        my $samplexml = $s->{name} . ".xml";
        $eutilsUrl =~ s/\&/\\\&/g;
        print "    fetching $eutilsUrl\n";
        $status = system "curl --silent --output $samplexml $eutilsUrl";
        if ($status != 0) {
            print "      ... failed!\n";
            next;
        }

        # Validate the XML
        $status = system "xmllint --noout --valid --nonet $samplexml";
        if ($status != 0) {
            print "    Failed to validate!\n";
            die;
        }
    }
}

