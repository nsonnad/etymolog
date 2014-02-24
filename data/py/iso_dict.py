#!/usr/bin/env python
import csv

# -------------------------------------------------------------------
# Make dictionary mapping language codes to their full English names
# -------------------------------------------------------------------


def make_iso_dict(iso3, iso2, iso5, retired):
    retired_tabin = csv.reader(retired, dialect=csv.excel_tab)
    iso5_tabin = csv.reader(iso5, dialect=csv.excel_tab)
    iso2_tabin = csv.reader(iso2, delimiter='|')
    iso3_tabin = csv.reader(iso3, dialect=csv.excel_tab)
    iso_dict = {}

    def add_entry(row, i_id, i_name):
        id = row[i_id]
        iso_dict[id] = row[i_name]

    # go from old to new iso codes so that newest values win out
    for row in retired_tabin:
        add_entry(row, 0, 1)

    for row in iso5_tabin:
        add_entry(row, 1, 2)

    for row in iso2_tabin:
        add_entry(row, 0, 3)

    for row in iso3_tabin:
        add_entry(row, 0, 6)

    return iso_dict
