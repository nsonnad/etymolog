#!/usr/bin/env python
import sys
import os
import csv

dir = os.path.dirname(os.path.abspath(__file__))
dir = os.path.abspath(os.path.join(dir, ".."))

etymwn_in = csv.reader(open(sys.argv[1]))
uniq_out = csv.writer(open(dir + '/' + sys.argv[2], 'wb'), delimiter='\t')

words = set()
for r in etymwn_in:
    word1 = (r[0], r[2], r[4], 'Word')
    word2 = (r[1], r[3], r[5], 'Word')

    if word1 not in words:
        words.add(word1)
    if word2 not in words:
        words.add(word2)

i = 0
print 'Writing csv of unique words and ids...'
uniq_out.writerow(['i:id', 'lang_name', 'word', 'lang_iso3', 'l:label'])

for word in words:
    word = list(word)
    word = [i] + word
    uniq_out.writerow(word)
    i += 1
