#!/usr/bin/bash

cd /home/maloneyc/git/klortho/Eutils-JSON/test
now=`date +"%Y%m%d%H%M%S"`

outfile_vxml=cron_out_vxml_$now.txt
echo "Running validate-xml.pl" > $outfile_vxml
/usr/bin/perl5.16 ./validate-xml.pl -c >> $outfile_vxml
echo "======================================================"
echo validate-xml results
tail $outfile_vxml


outfile_vjson=cron_out_vjson_$now.txt
echo "Running validate-json.pl" > $outfile_vjson
/usr/bin/perl5.16 ./validate-json.pl -c >> $outfile_vjson
echo "======================================================"
echo validate-json results
tail $outfile_vjson



