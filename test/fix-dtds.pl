#!/usr/bin/perl

while (<>) {
    s/\t\t\t\>/\"\>/;
    s/\<object\/\>n/\<object\/\>\n/;
    s/\% T_DocSum \"\(/\% T_DocSum \"\(\(/;
    s/\| error/\| error\)/;
    print;
}