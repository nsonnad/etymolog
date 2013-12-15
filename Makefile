OBJECTS = \
		output/clean_etymwn.csv \
		input/iso-639-3.tab \
		input/iso-639-2.txt \
		input/iso-639-5.tsv \
		input/retired-iso.tab \
		input/etymwn.tsv 

all: ${OBJECTS}

input/iso-639-3.tab:
		@echo "\nGetting iso-639-3 codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@ 'http://www-01.sil.org/iso639-3/iso-639-3.tab'
		touch $@

input/iso-639-2.txt:
		@echo "\nGetting iso-639-2 codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@ 'http://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt'
		touch $@

input/iso-639-5.tsv:
		@echo "\nGetting iso-639-5 codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@ 'http://id.loc.gov/vocabulary/iso639-5.tsv'
		touch $@

input/retired-iso.tab:
		@echo "\nGetting retired iso codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@ 'http://www-01.sil.org/iso639-3/iso-639-3_Retirements.tab'
		touch $@

input/etymwn.tsv:
		@echo "\nUnzipping etymological data..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		unzip input/etymwn-20130208.zip -d input
		touch $@
		@echo "\nRemoving commas from TSV file..."
		@echo "-----------------------------------------------------------"
		sed -i "" 's/,//g' $@

output/clean_etymwn.csv: input/iso-639-3.tab input/iso-639-2.txt input/iso-639-5.tsv input/retired-iso.tab input/etymwn.tsv
		@echo "\nParsing etymology wordnet TSV into CSV with language names..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		python py/clean_tsv.py input/etymwn.tsv $@

