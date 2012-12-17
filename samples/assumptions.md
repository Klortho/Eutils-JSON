# Assumptions

Here are some assumptions we made while mapping DTD elements to JSON.
These might be incorrect, which, in most cases, would mean that there would be
some XML instance documents that are valid according to the DTD that would
result in invalid JSON output.


## eSummary_pmd.dtd
* <Author> → object
* <DocumentSummary> → object
* <ArticleId> → object

## eSummary_unists.dtd
* <DocumentSummary> → object
* <Map_Gene_Summary> → object

## eSummary_nuccore.dtd
* <DocumentSummarySet> → object; in this case, what if it contains Warnings?


