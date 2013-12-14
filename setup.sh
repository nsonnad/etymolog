if [[ ! -f etymwn.zip ]]; then
  curl -o etymwn.zip 'http://www.mpi-inf.mpg.de/~gdemelo/downloads/etymwn-20130208.zip'
  unzip etymwn.zip
fi

echo Removing commas from etymwn.tsv...
sed -i "" 's/,//g' etymwn.tsv

echo Converting etymwn.tsv to structured csv...
python clean_tsv.py etymwn.tsv cleaned_etym.csv

echo Cleaning up...
if [[ ! -f etymwn.tsv]]; then
  rm etymwn.tsv
fi
