#!/usr/bin/env python
import sys
import re
import csv

def make_iso_dict(iso3, iso2, iso5, retired):
    iso3_tabin = csv.reader(iso3, dialect=csv.excel_tab)
    iso2_tabin = csv.reader(iso2, delimiter='|')
    iso5_tabin = csv.reader(iso5, dialect=csv.excel_tab)
    retired_tabin = csv.reader(retired, dialect=csv.excel_tab)
    iso_dict = {}

    for row in iso3_tabin:
        id = row[0]
        name = row[6]
        iso_dict[id] = name
        
    for row in iso2_tabin:
        id = row[0]
        if id not in iso_dict.keys():
            iso_dict[id] = row[3]

    for row in iso5_tabin:
        id = row[1]
        if id not in iso_dict.keys():
            iso_dict[id] = row[2]

    for row in retired_tabin:
        id = row[0]
        if id not in iso_dict.keys():
            iso_dict[id] = row[1]

    return iso_dict

