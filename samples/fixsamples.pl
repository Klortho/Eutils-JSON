#!/usr/bin/perl
use strict;

my $readme = "README.md";

open R, $readme or die "Can't open $readme for reading";
my $new = "";
while (my $line = <R>) {
    last if $line eq "<div>\n";
    $new .= $line;
}
close R;

my $table = "temp-table.xml";
system "xsltproc make-sample-readme-table.xsl samples.xml > $table";
my $status = $? >> 8;
if ($status) {
    die "Failed to transform samples.xml into $table";
}

open T, $table or die "Failed to open $table for reading";
while (my $line = <T>) {
    $new .= $line;
}
close T;
unlink $table;

open R, ">$readme" or die "Can't open $readme for writing";
print R $new;
close R;


#print $new;
