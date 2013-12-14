#!/usr/bin/env python
import sys
import re
import csv

tabin = open(sys.argv[1])
commaout = open(sys.argv[2], 'wb')

junk_to_replace = re.compile(r'(\"|\'|rel\:)')
category_exception = re.compile(r'(\:)?Category:[^,]+')

tabin = csv.reader(tabin, dialect=csv.excel_tab)

commaout = csv.writer(commaout, dialect=csv.excel)
commaout.writerow(['lang1','word1','lang2','word2'])

for row in tabin:
    # convert to single csv string (cuts down on loops as well)
    row = ','.join(row)
    # only get etymology relationships
    if 'rel:etymology' in row:
        # remove junk
        row = re.sub(junk_to_replace, '', row)
        # category exception
        category = category_exception.search(row)
        if category:
            g = category.group()
            row = row.replace(g, g.split()[-1])
        # separate interesting values
        clean = re.sub(r'(\w+):\s', r'\1,', row).split(',')
        # remove etymology relationship
        clean = [clean[i] for i in range(0,5) if i != 2] 
        # write to file
        commaout.writerow(clean)
