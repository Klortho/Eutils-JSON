Eutils-JSON-Proxy
===========

Eutils-json-proxy is rack application that converts eutils xml to json

This is a demo app contributed by [sdor](https://github.com/sdor) (Thanks!)
and is not deployed anywhere, nor are there plans (at present) to deploy it.
This is one alternative way to implement the XML-to-JSON conversion, and is
here for comparison purposes.

## Installation and running the server

1. Install Ruby or JRuby

2. In this `rack-proxy` directory, run: `bundle`

3. To run the server, from this `rack-proxy` directory, run:

      puma app.ru -b tcp://localhost:8080 -t 4:100 --workers 4

This should start a local server running on port 8080.

## Implementation

This server acts as a reverse-proxy from NCBI E-utilities, and uses nokogiri
to parse the XML (nokogiri is the ruby binding to libxml2).  noris is a Ruby
gem that produces a map to convert the XML into JSON.

## Example

In a browser, navigate to:

[http://localhost:8080/entrez/eutils/esearch.fcgi?db=pubmed&term=science%5Bjournal%5D+AND+breast+cancer+AND+2008%5Bpdat%5D]()

Response should be (prettified for readability):

    {
        "eSearchResult": {
        "Count": "6",
        "RetMax": "6",
        "RetStart": "0",
        "IdList": {
            "Id": [
            "19008416",
            "18927361",
            "18787170",
            "18487186",
            "18239126",
            "18239125"
            ]
        },
        "TranslationSet": {
            "Translation": [
            {
                "From": "science[journal]",
                "To": "\"Science\"[Journal] OR \"Science (80- )\"[Journal] OR \"J Zhejiang Univ Sci\"[Journal]"
            },
            {
                "From": "breast cancer",
                "To": "\"breast neoplasms\"[MeSH Terms] OR (\"breast\"[All Fields] AND \"neoplasms\"[All Fields]) OR \"breast neoplasms\"[All Fields] OR (\"breast\"[All Fields] AND \"cancer\"[All Fields]) OR \"breast cancer\"[All Fields]"
            }
            ]
        },
        "TranslationStack": {
            "TermSet": [
            {
                "Term": "\"Science\"[Journal]",
                "Field": "Journal",
                "Count": "163324",
                "Explode": "N"
            },
            {
                "Term": "\"Science (80- )\"[Journal]",
                "Field": "Journal",
                "Count": "10",
                "Explode": "N"
            },
            {
                "Term": "\"J Zhejiang Univ Sci\"[Journal]",
                "Field": "Journal",
                "Count": "364",
                "Explode": "N"
            },
            {
                "Term": "\"breast neoplasms\"[MeSH Terms]",
                "Field": "MeSH Terms",
                "Count": "204516",
                "Explode": "Y"
            },
            {
                "Term": "\"breast\"[All Fields]",
                "Field": "All Fields",
                "Count": "332693",
                "Explode": "N"
            },
            {
                "Term": "\"neoplasms\"[All Fields]",
                "Field": "All Fields",
                "Count": "1938750",
                "Explode": "N"
            },
            {
                "Term": "\"breast neoplasms\"[All Fields]",
                "Field": "All Fields",
                "Count": "204591",
                "Explode": "N"
            },
            {
                "Term": "\"breast\"[All Fields]",
                "Field": "All Fields",
                "Count": "332693",
                "Explode": "N"
            },
            {
                "Term": "\"cancer\"[All Fields]",
                "Field": "All Fields",
                "Count": "1340351",
                "Explode": "N"
            },
            {
                "Term": "\"breast cancer\"[All Fields]",
                "Field": "All Fields",
                "Count": "162927",
                "Explode": "N"
            },
            {
                "Term": "2008[pdat]",
                "Field": "pdat",
                "Count": "829084",
                "Explode": "N"
            }
            ],
            "OP": [
            "OR",
            "OR",
            "GROUP",
            "AND",
            "GROUP",
            "OR",
            "OR",
            "AND",
            "GROUP",
            "OR",
            "OR",
            "GROUP",
            "AND",
            "AND"
            ]
        },
        "QueryTranslation": "(\"Science\"[Journal] OR \"Science (80- )\"[Journal] OR \"J Zhejiang Univ Sci\"[Journal]) AND (\"breast neoplasms\"[MeSH Terms] OR (\"breast\"[All Fields] AND \"neoplasms\"[All Fields]) OR \"breast neoplasms\"[All Fields] OR (\"breast\"[All Fields] AND \"cancer\"[All Fields]) OR \"breast cancer\"[All Fields]) AND 2008[pdat]"
        },
        "status": "ok"
    }
