// base modules
var fs = require('fs');
var csv = require('csv');
var path = require('path');
var http = require('http');
var bl = require('bl');
var async = require('async');

// POST a word with properties
// ---------------------------
var postOptions = {
    hostname: 'localhost',
    port: 7474,
    path: '/db/data/cypher',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'charset': 'UTF-8'
    }
  };

function postWord (wordName, language, callback) {
  var postReq = http.request(postOptions, function (res) {
    res.pipe(bl(function (err, data) {
      callback(null, JSON.parse(data.toString()).data[0][0]);
    }));
  });

  var wordReq = {
    'query': 'CREATE (n:Word { props }) RETURN n',
    'params': {
      'props': {
        'language': language,
        'wordName': wordName
      }
    }
  };
  postReq.write(JSON.stringify(wordReq));
  postReq.end();
}

function getOptions (wordName, language) {
  var options = {
      hostname: 'localhost',
      port: 7474,
      path: '/db/data/label/Word/nodes?wordName="' + wordName + '"?language="' + language + '"',
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'charset': 'UTF-8'
      }
    };
  
  return options;
}

// Get a word's json and pass it to checker func
// ----------------------------------------
function getWordData (record, callback) {
  var word1 = record.word1;
  var lang1 = record.lang1_iso;
  var word2 = record.word2;
  var lang2 = record.lang2_iso;

  http.get(getOptions(word1, lang1), function (res1) {
    http.get(getOptions(word2, lang2), function (res2) {
      res1.pipe(bl(function (err, data1) {
        res2.pipe(bl(function (err, data2) {
          callback(record, data1.toString(), data2.toString());
        }));
      }));
    });
  });
}

function relation (word1, word2, relUrl) {
  console.log(word1, word2, relUrl);
  http.get(relUrl, function (res) {
    res.pipe(bl(function (err, data) {
      //console.log(data.toString());
    }));
  });
}

function processNode (record, word1res, word2res) {
  // parse word data
  var wordData1 = (word1res.length > 3) ? JSON.parse(word1res)[0] : null;
  var wordData2 = (word2res.length > 3) ? JSON.parse(word2res)[0] : null;
  
  async.parallel([
    function (callback) {
      if (!wordData1) {
        console.log('posting word1 data');
        postWord(record.word1, record.lang1_iso3, callback);
      } else {
        console.log('word1 exists');
        callback(null, wordData1);
      }
    },
    function (callback) {
      if (!wordData2) {
        console.log('posting word2 data');
        postWord(record.word2, record.lang2_iso3, callback);
      } else {
        console.log('word2 exists');
        callback(null, wordData2);
      }
    }
  ],
  function (err, result) {
    console.log(result);
  });
  
  // check for relationship, creating if not there
  
}

var eg = {
  lang1_name: 'Breton',
  lang2_name: 'Latin',
  word1: 'hello',
  word2: 'Coltrane',
  lang1_iso3: 'eng',
  lang2_iso3: 'lat' 
};

getWordData(eg, processNode);

// import csv
var csvPath = process.cwd() + path.resolve(__filename, '/data/output/sliced.csv');

var parser = csv().from.stream(fs.createReadStream(csvPath), { columns: true });
parser.on('record', function (record) {
  //console.log(record);
  //
});

