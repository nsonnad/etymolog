##Etymolog

For now, this project produces a clean CSV of word relationships by cleaning up and parsing data from
the [Etymological Wordnet](http://www1.icsi.berkeley.edu/~demelo/etymwn/). Resulting CSV shows source and target words, as well as the full names of languages they belong to (by looking up info on the ISO codes provided).

I aim in the future to turn this into a searchable network visualization of word
relatonships.

To produce the file (by default `cleaned_etym.csv`), do the following:

    `git clone git@github.com:nsonnad/etymolog.git`
    `cd etymolog`
    `make`

