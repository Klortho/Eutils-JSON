#!/usr/bin/bash

cd /home/maloneyc/git/Klortho/Eutils-JSON/test

echo "========================================================" | tee -a ./cron-out.txt
echo "Running Eutils-JSON tests" | tee -a ./cron-out.txt
date | tee -a ./cron-out.txt

/opt/perl-5.8.8/bin/perl ./validate-xml.pl --tld=try -c  | tee -a ./cron-out.txt
/opt/perl-5.8.8/bin/perl ./validate-json.pl --tld=try -c | tee -a ./cron-out.txt



