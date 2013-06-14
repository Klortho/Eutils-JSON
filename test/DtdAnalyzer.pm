# This package manages the interface to the DtdAnalyzer tool.  In particular,
# the dtd2xml2json utility.
# This acts as a singleton class that's accessed through the instance() method.
# This uses lazy initialization for the dtd2xml2json utility, so that it will
# only cause an error if there is actually an attempt to use it.

package DtdAnalyzer;

use strict;
use warnings;

# Singleton.
my $inst;


#----------------------------------------------------------
sub instance {
    my $class = shift;
    if (!defined $inst) {
        $inst = {
            'initialized' => 0,
        };
        bless $inst, $class;
    }
    return $inst;
}

#----------------------------------------------------------
# This returns 0 on success, or the command line that was used to execute
# the utility on error.

sub dtd2xml2json {
    my ($self, $dtdSrc, $jsonXslPath, $outfile) = @_;

    # Lazy initialization - do it now.
    if (!$self->{initialized}) { $self->initialize(); }

    my $cmd = "dtd2xml2json $dtdSrc $jsonXslPath > $outfile 2>&1";
    $self->message("Creating XSLT $jsonXslPath");
    my $status = system $cmd;
    return $status ? $cmd : 0;
}

#----------------------------------------------------------
sub initialize {
    my $self = shift;

    # Get the XSLT base stylesheet, xml2json.xsl, into the out directory
    my $ddir = which('dtd2xml2json');
    if (!$ddir) {
        die "Can't find dtd2xml2json in my PATH.  That's not good.";
    }
    $ddir =~ s/^(.*)\/.*$/$1\//;
    my $basexslt = $ddir . 'xslt/xml2json.xsl';
    if (!-f $basexslt) {
        die "Can't find the base XSLT file $basexslt.  That's bad.";
    }
    copy($basexslt, 'out');

    $self->{initialized} = 1;
}

1;
