#!/usr/bin/env python
import sys
import os
import re
import csv
from iso_dict import make_iso_dict

# -------------------------------------------------------------------
# Extract language information for etymological relationships
# and add in full English names
# -------------------------------------------------------------------

dir = os.path.dirname(os.path.abspath(__file__))
dir = os.path.abspath(os.path.join(dir, ".."))

# the files we need
etymwn_tabin = open(sys.argv[1])
iso3_tabin = open(dir + '/input/iso-639-3.tab')
iso2_tabin = open(dir + '/input/iso-639-2.txt')
iso5_tabin = open(dir + '/input/iso-639-5.tsv')
retired_tabin = open(dir + '/input/retired-iso.tab')
csvout = open(dir + '/' + sys.argv[2], 'wb')

print 'Building hash of iso codes -> names...'
iso_dict = make_iso_dict(iso3_tabin, iso2_tabin, iso5_tabin, retired_tabin)

etymwn_tabin = csv.reader(etymwn_tabin, dialect=csv.excel_tab)
rows = []

# regexes for cleaning
junk_to_replace = re.compile(r'(\"|\'|rel\:)')
category_exception = re.compile(r'(\:)?Category:[^,]+')


def get_lang_name(name):
    if name.startswith('p_'):
        return iso_dict[name[2:]]
    else:
        return iso_dict[name]


# func to add rows combining etymwn and iso code data
def add_row(row_data):
    # remove junk
    row_data = re.sub(junk_to_replace, '', row_data)
    # category exception
    category = category_exception.search(row_data)
    if category:
        g = category.group()
        row_data = row_data.replace(g, g.split()[-1])
    # separate interesting values
    clean = re.sub(r'(\w+):\s', r'\1,', row_data).split(',')
    # remove etymology relationship
    clean = [clean[i] for i in range(0, 5) if i != 2]
    if clean[3].startswith('-') or clean[3].endswith('-'):
        return
    else:
        # add final values
        rows.append({
            'lang1_iso3':  clean[0],
            'lang1_name':  get_lang_name(clean[0]),
            'word1':       clean[1],
            'lang2_iso3':  clean[2],
            'lang2_name':  get_lang_name(clean[2]),
            'word2':       clean[3]
            })


# cycle through rows, adding relevant info
print 'Processing data...'
for row in etymwn_tabin:
    # convert to single csv string (cuts down on loops as well)
    row = ','.join(row)
    # only get etymology relationships
    if 'rel:etymology' in row:
        add_row(row)

# write dict of rows to csv
keys = rows[0].keys()
print 'Writing CSV...'
write_dict = csv.DictWriter(csvout, keys)
write_dict.writer.writerow(keys)
write_dict.writerows(rows)
