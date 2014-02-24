OBJECTS = \
		etymwn.db \
		db/import.sh \
		db/neo4j-batch-importer.zip \
		db/relationships.csv \
		db/uniq_words.csv \
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
		curl -o $@.download 'http://www-01.sil.org/iso639-3/iso-639-3.tab'
		mv $@.download $@

input/iso-639-2.txt:
		@echo "\nGetting iso-639-2 codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'http://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt'
		mv $@.download $@

input/iso-639-5.tsv:
		@echo "\nGetting iso-639-5 codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'http://id.loc.gov/vocabulary/iso639-5.tsv'
		mv $@.download $@

input/retired-iso.tab:
		@echo "\nGetting retired iso codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'http://www-01.sil.org/iso639-3/iso-639-3_Retirements.tab'
		mv $@.download $@

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

db/uniq_words.csv: output/clean_etymwn.csv
		@echo "\nCreating csv of unique words..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		python py/uniq_words.py output/clean_etymwn.csv $@

db/relationships.csv: output/clean_etymwn.csv db/uniq_words.csv
		@echo "\nCreating csv of unique words..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		python py/relationships.py db/uniq_words.csv output/clean_etymwn.csv $@

db/neo4j-batch-importer.zip:
		@echo "\nFetching neo4j batch importer..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'https://dl.dropboxusercontent.com/u/14493611/batch_importer_20.zip'
		mv $@.download $@

db/import.sh: db/neo4j-batch-importer.zip
		mkdir -p $(dir $@)
		unzip -d db/ db/neo4j-batch-importer.zip
		touch db/import.sh

etymwn.db: db/import.sh db/relationships.csv db/uniq_words.csv
		cd db; ./import.sh $@ uniq_words.csv relationships.csv; cd -

clean:
		rm -rf db/ output/
