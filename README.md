Deprecated!
===========

This repository was used as a test/staging area for work to prepare to provide JSON
output for NCBI [E-utilities](http://www.ncbi.nlm.nih.gov/books/NBK25501/).

That output format is now available.  Please see the Entrez Programming Utilities Help book,
[E-utilities in Depth](http://www.ncbi.nlm.nih.gov/books/NBK25499/) for more information.

Please send an email to
[eutilities@ncbi.nlm.nih.gov](mailto:eutilities@ncbi.nlm.nih.gov) if you have any questions.

----

Conversion XSLTs for NCBI [E-utilities](http://www.ncbi.nlm.nih.gov/books/NBK25501/) XML to JSON.


## Samples / test cases

The `samples` directory here provides a large number of samples of E-utility
XML responses, DTDs, etc.  This was where preliminary investigations were done,
and a list of problems were identified in the current XML outputs.

## Test script

The `test` directory here contains a feature-rich test script, along with a
`testcases.xml` file that identifies an extensive set of test cases.

## Ruby / Rack application

The `rack-proxy` directory here contains a simple Ruby application that uses
the Puma server to reverse-proxy Eutilities requests and convert them into
JSON.

Thanks to @sdor for this pull request.


# Public Domain notice

National Center for Biotechnology Information.

This software is a "United States Government Work" under the terms of the
United States Copyright Act.  It was written as part of the authors'
official duties as United States Government employees and thus cannot
be copyrighted.  This software is freely available to the public for
use. The National Library of Medicine and the U.S. Government have not
placed any restriction on its use or reproduction.

Although all reasonable efforts have been taken to ensure the accuracy
and reliability of the software and data, the NLM and the U.S.
Government do not and cannot warrant the performance or results that
may be obtained by using this software or data. The NLM and the U.S.
Government disclaim all warranties, express or implied, including
warranties of performance, merchantability or fitness for any
particular purpose.

Please cite NCBI in any work or product based on this material.


