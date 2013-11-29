if [[ ! -f etymwn.zip ]]; then
  curl -o etymwn.zip 'http://www.mpi-inf.mpg.de/~gdemelo/downloads/etymwn-20130208.zip'
  unzip etymwn.zip
fi

sed -i "" 's/,//g' etymwn.tsv
python clean_tsv.py etymwn.tsv cleaned_etym.csv