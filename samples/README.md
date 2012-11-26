# Samples / test cases

<h2>EInfo</h2>
<table>
   <tr>
      <th></th>
      <th>Status</th>
      <th rowspan="2">Local files</th>
      <th>Comment</th>
      <th>NCBI EUtils</th>
   </tr>
   <tr>
      <th>EInfo</th>
      <td>&#10003;</td>
      <td><a href="../../blob/master/samples/einfo.xml">xml</a></td>
      <td><a href="../../blob/master/samples/einfo.json">json</a></td>
      <td>List all databases</td>
      <td><a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi">http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi</a></td>
   </tr>
   <tr>
      <th>EInfo PubMed</th>
      <td>&#10003;</td>
      <td><a href="../../blob/master/samples/einfo.pubmed.xml">xml</a></td>
      <td><a href="../../blob/master/samples/einfo.pubmed.json">json</a></td>
      <td></td>
      <td><a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed">http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed</a></td>
   </tr>
   <tr>
      <th>EInfo Error</th>
      <td>&#10003;</td>
      <td><a href="../../blob/master/samples/einfo.error.xml">xml</a></td>
      <td><a href="../../blob/master/samples/einfo.error.json">json</a></td>
      <td>Invalid database name</td>
      <td><a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=fleegle">http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=fleegle</a></td>
   </tr>
</table>
<h2>ESearch</h2>
<table>
   <tr>
      <th></th>
      <th>Status</th>
      <th rowspan="2">Local files</th>
      <th>Comment</th>
      <th>NCBI EUtils</th>
   </tr>
   <tr>
      <th>ESearch PubMed</th>
      <td>&#10003;</td>
      <td><a href="../../blob/master/samples/esearch.pubmed.xml">xml</a></td>
      <td><a href="../../blob/master/samples/esearch.pubmed.json">json</a></td>
      <td></td>
      <td><a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&amp;term=cancer&amp;reldate=60&amp;datetype=edat&amp;retmax=100&amp;usehistory=y">http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&amp;term=cancer&amp;reldate=60&amp;datetype=edat&amp;retmax=100&amp;usehistory=y</a></td>
   </tr>
   <tr>
      <th>ESearch Error</th>
      <td>&#10003;</td>
      <td><a href="../../blob/master/samples/esearch.error.xml">xml</a></td>
      <td><a href="../../blob/master/samples/esearch.error.json">json</a></td>
      <td>This query has a bad search term</td>
      <td><a href="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nlmcatalog&amp;term=obstetrics%5bMeSH%20Terms%5d+OR+fleegle%5bMeSH%20Terms%5d">http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=nlmcatalog&amp;term=obstetrics%5bMeSH%20Terms%5d+OR+fleegle%5bMeSH%20Terms%5d</a></td>
   </tr>
</table>