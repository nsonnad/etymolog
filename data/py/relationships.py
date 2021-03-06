#!/usr/bin/env python
import sys
import os
import csv
from collections import defaultdict

uniq_in = csv.DictReader(open(sys.argv[1]), delimiter='\t')
data_in = csv.DictReader(open(sys.argv[2]))
rels_out = csv.writer(open(sys.argv[3], 'wb'), delimiter='\t')

wordlookup = defaultdict(list)
for line in uniq_in:
    wordlookup[line['word']] = line


print 'Writing relationships csv...'
rels_out.writerow(['start', 'end', 'type', 'target', 'origin'])
#rels_out.writerow(['start', 'end', 'type'])
for line in data_in:
    id1 = wordlookup[line['word1']]['i:id']
    id2 = wordlookup[line['word2']]['i:id']
    relation = [id2, id1, 'ORIGIN_OF', line['word1'], line['word2']]
    #relation = [id2, id1, 'ORIGIN_OF']

    rels_out.writerow(relation)
