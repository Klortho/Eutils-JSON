Eutils-JSON-Proxy
===========

Eutils-json-proxy is rack application that converts eutils xml to json

##Installation
 1. Install Ruby or JRuby
 2. In eutils-json-proxy directory run:
    bundle

##Example
In eutils-json-proxy directory run:

   puma app.ru -b tcp://localhost:8080 -t 4:100 --workers 4

In browser navigate to:

  http://localhost:8080/entrez/eutils/esearch.fcgi?db=pubmed&term=science[journal]+AND+breast+cancer+AND+2008[pdat]


Response should be:

  {"eSearchResult":
    { "Count":"6",
      "RetMax":"6",
      "RetStart":"0",
      "IdList":{"Id":["19008416","18927361","18787170","18487186","18239126","18239125"]},
      "TranslationSet":{
        "Translation":[
           {"From":"science[journal]","To":"\"Science\"[Journal] OR \"Science (80- )\"[Journal] OR \"J Zhejiang Univ Sci\"[Journal]"},
           {"From":"breast cancer","To":"\"breast neoplasms\"[MeSH Terms] OR (\"breast\"[All Fields] AND \"neoplasms\"[All Fields]) OR \"breast neoplasms\"[All Fields] OR (\"breast\"[All Fields] AND \"cancer\"[All Fields]) OR \"breast cancer\"[All Fields]"}
          ]},
      "TranslationStack":{
           "TermSet":[
                {"Term":"\"Science\"[Journal]","Field":"Journal","Count":"163155","Explode":"N"},
                {"Term":"\"Science (80- )\"[Journal]","Field":"Journal","Count":"10","Explode":"N"},
                {"Term":"\"J Zhejiang Univ Sci\"[Journal]","Field":"Journal","Count":"364","Explode":"N"},
                {"Term":"\"breast neoplasms\"[MeSH Terms]","Field":"MeSH Terms","Count":"203202","Explode":"Y"},
                {"Term":"\"breast\"[All Fields]","Field":"All Fields","Count":"330386","Explode":"N"},
                {"Term":"\"neoplasms\"[All Fields]","Field":"All Fields","Count":"1928547","Explode":"N"},
                {"Term":"\"breast neoplasms\"[All Fields]","Field":"All Fields","Count":"203253","Explode":"N"},
                {"Term":"\"breast\"[All Fields]","Field":"All Fields","Count":"330386","Explode":"N"},
                {"Term":"\"cancer\"[All Fields]","Field":"All Fields","Count":"1329499","Explode":"N"},
                {"Term":"\"breast cancer\"[All Fields]","Field":"All Fields","Count":"161475","Explode":"N"},
                {"Term":"2008[pdat]","Field":"pdat","Count":"829027","Explode":"N"}],"OP":["OR","OR","GROUP","AND","GROUP","OR","OR","AND","GROUP","OR","OR","GROUP","AND","AND"]},
      "QueryTranslation":"(\"Science\"[Journal] OR \"Science (80- )\"[Journal] OR \"J Zhejiang Univ Sci\"[Journal]) AND (\"breast neoplasms\"[MeSH Terms] OR (\"breast\"[All Fields] AND \"neoplasms\"[All Fields]) OR \"breast neoplasms\"[All Fields] OR (\"breast\"[All Fields] AND \"cancer\"[All Fields]) OR \"breast cancer\"[All Fields]) AND 2008[pdat]"},
   "status":"ok"}
