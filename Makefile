NEO4J_VERSION=neo4j-community-2.0.0
ETYMWN_FILE=etymwn-20130208.zip

OBJECTS = \
		neo4j \
		${NEO4J_VERSION}-unix.tar.gz \
		${NEO4J_VERSION}/data/graph.db \
		data/db/import.sh \
		data/db/neo4j-batch-importer.zip \
		data/db/relationships.csv \
		data/db/uniq_words.csv \
		data/output/clean_etymwn.csv \
		data/input/iso-639-3.tab \
		data/input/iso-639-2.txt \
		data/input/iso-639-5.tsv \
		data/input/retired-iso.tab \
		data/input/etymwn.tsv \
		data/input/${ETYMWN_FILE} \
		app/node_modules

all: ${OBJECTS}

${NEO4J_VERSION}-unix.tar.gz:
		@echo "\nFetching neo4j of version: ${NEO4J_VERSION}"
		@echo "-----------------------------------------------------------"
		curl http://dist.neo4j.org/${NEO4J_VERSION}-unix.tar.gz --O ${NEO4J_VERSION}-unix.tar.gz

neo4j: ${NEO4J_VERSION}-unix.tar.gz
		@echo "\nUnzipping neo4j..."
		@echo "-----------------------------------------------------------"
		tar -zxvf ${NEO4J_VERSION}-unix.tar.gz
		ln -s ${NEO4J_VERSION}/bin/neo4j neo4j
		rm -rf ${NEO4J_VERSION}/data/graph.db

data/input/iso-639-3.tab:
		@echo "\Fetching iso-639-3 codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'http://www-01.sil.org/iso639-3/iso-639-3.tab'
		mv $@.download $@

data/input/iso-639-2.txt:
		@echo "\Fetching iso-639-2 codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'http://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt'
		mv $@.download $@

data/input/iso-639-5.tsv:
		@echo "\Fetching iso-639-5 codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'http://id.loc.gov/vocabulary/iso639-5.tsv'
		mv $@.download $@

data/input/retired-iso.tab:
		@echo "\Fetching retired iso codes..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'http://www-01.sil.org/iso639-3/iso-639-3_Retirements.tab'
		mv $@.download $@

data/input/${ETYMWN_FILE}:
		@echo "\Fetching etymological data..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download http://www.mpi-inf.mpg.de/~gdemelo/downloads/${ETYMWN_FILE}
		mv $@.download $@

data/input/etymwn.tsv: data/input/${ETYMWN_FILE}
		@echo "\nUnzipping etymological data..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		unzip data/input/${ETYMWN_FILE} -d data/input
		touch $@
		@echo "\nRemoving commas from TSV file..."
		@echo "-----------------------------------------------------------"
		sed -i "" 's/,//g' $@

data/output/clean_etymwn.csv: data/input/iso-639-3.tab data/input/iso-639-2.txt data/input/iso-639-5.tsv data/input/retired-iso.tab data/input/etymwn.tsv
		@echo "\nParsing etymology wordnet TSV into CSV with language names..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		python data/py/clean_tsv.py data/input/etymwn.tsv $@

data/db/uniq_words.csv: data/output/clean_etymwn.csv
		@echo "\nCreating csv of unique words..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		python data/py/uniq_words.py data/output/clean_etymwn.csv $@

data/db/relationships.csv: data/output/clean_etymwn.csv data/db/uniq_words.csv
		@echo "\nCreating csv of unique words..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		python data/py/relationships.py data/db/uniq_words.csv data/output/clean_etymwn.csv $@

data/db/neo4j-batch-importer.zip:
		@echo "\nFetching neo4j batch importer..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		curl -o $@.download 'https://dl.dropboxusercontent.com/u/14493611/batch_importer_20.zip'
		mv $@.download $@

data/db/import.sh: data/db/neo4j-batch-importer.zip
		@echo "\nUnzipping neo4j batch importer..."
		@echo "-----------------------------------------------------------"
		mkdir -p $(dir $@)
		unzip -d data/db/ data/db/neo4j-batch-importer.zip
		touch data/db/import.sh

${NEO4J_VERSION}/data/graph.db: data/db/import.sh data/db/relationships.csv data/db/uniq_words.csv
		@echo "\nImporting data into neo4j database..."
		@echo "-----------------------------------------------------------"
		cd data/db; ./import.sh graph.db uniq_words.csv relationships.csv; cd -
		cp -r data/db/graph.db $@ && rm -rf data/db/graph.db

app/node_modules:
		@echo "\nInstalling npm modules..."
		@echo "-----------------------------------------------------------"
		cd app; npm install; cd -

clean:
		@echo "\nCleaning..."
		@echo "-----------------------------------------------------------"
		rm -rf neo4j ${NEO4J_VERSION} data/db/ data/input data/output/ app/node_modules
