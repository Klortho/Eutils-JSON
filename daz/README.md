# DtdAnalyzer versions of DTDs

This directory has copies of the DTDs that have been modified with
DtdAnalyzer annotations.

## Simplifying assumptions

I won't have time to make this robust and able to cover all possible cases.
Here are some of the things that I'm assuming.

* There will only be one root element (@root = true).
  For example, for EInfo documents, the root element
  will always be eInfoResult
* That root element will never appear as a child of another element.
