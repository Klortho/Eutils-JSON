package EutilsJson;

use XML::LibXML;


our @dbs = qw(
    assembly bioproject biosample biosystems blastdbinfo books
    cdd clone dbvar epigenomics gap gapplus gcassembly gds
    gencoll gene genome genomeprj geoprofiles homologene
    journals medgen mesh ncbisearch nlmcatalog nuccore nucest
    nucgss nucleotide omia omim pcassay pccompound pcsubstance
    pmc popset probe protein proteinclusters pubmed pubmedhealth
    seqannot snp sra structure taxonomy toolkit toolkitall
    toolkitbook unigene unists
);

# Base URL of the eutilities services
our $eutilsBaseUrl = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';

#-------------------------------------------------------------
# Read the samples.xml file and produce a structure that looks like
# this:
#   [
#     { dtd => 'eInfo_020511.dtd',
#       idx => 0,
#       eutil => 'einfo',
#       samples => [
#         { name => 'einfo',
#           db => 'pubmed',
#           eutils-url => '....', },
#       ]
#     } ...
#   ]

sub readSamples {
    my $parser = new XML::LibXML;
    my $sxml = $parser->load_xml(location => 'samples.xml')->getDocumentElement();

    my @samples = ();
    foreach my $sg ($sxml->getChildrenByTagName('samplegroup')) {
        my %samplegroup = (
            dtd => $sg->getAttribute('dtd'),
            idx => ($sg->getAttribute('idx') eq 'true'),
            eutil => $sg->getAttribute('eutil'),
        );

        my @groupsamples = ();
        foreach my $samp ($sg->getChildrenByTagName('sample')) {
            my %gs = (
                name => $samp->getAttribute('name'),
                db => $samp->getAttribute('db'),
                'eutils-url' =>
                  ($samp->getChildrenByTagName('eutils-url'))[0]->textContent(),
            );
            push @groupsamples, \%gs;
            $samplegroup{samples} = \@groupsamples;
        }
        push @samples, \%samplegroup;
    }

    return \@samples;
}


