if [[ ! -f etymwn.zip ]]; then
  echo Downloading etymology data from Etymology WordNet...
  curl -o etymwn.zip 'http://www.mpi-inf.mpg.de/~gdemelo/downloads/etymwn-20130208.zip'
fi

if [[ ! -f etymwn.tsv ]]; then
  unzip etymwn.zip
fi

if [[ ! -f iso-639-3.tab ]]; then
  echo Downloading iso-639-3 codes...
  curl -o iso-639-3.tab 'http://www-01.sil.org/iso639-3/iso-639-3.tab'
fi

if [[ ! -f iso-639-2.txt ]]; then
  echo Downloading iso-639-2 codes...
  curl -o iso-639-2.txt 'http://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt'
fi

if [[ ! -f iso-639-5.tsv ]]; then
  echo Downloading iso-639-5 codes...
  curl -o iso-639-5.tsv 'http://id.loc.gov/vocabulary/iso639-5.tsv'
fi

if [[ ! -f retired-iso.tab ]]; then
  echo Downloading retired iso codes...
  curl -o retired-iso.tab 'http://www-01.sil.org/iso639-3/iso-639-3_Retirements.tab'
fi

echo Removing commas from etymwn.tsv...
sed -i "" 's/,//g' etymwn.tsv

echo Converting etymwn.tsv to structured csv...
python clean_tsv.py etymwn.tsv cleaned_etym.csv

echo "Delete source files?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) rm etymwn.tsv iso-639-3.tab iso-639-2.txt iso-639-5.tsv retired-iso.tab; break;;
        No ) exit;;
    esac
done

echo All done!
