// base modules
var fs = require('fs');
var csv = require('csv');
var path = require('path');
var http = require('http');
var bl = require('bl');
var async = require('async');
var request = require('request');

// POST a word with properties
// ---------------------------
var postOptions = {
    hostname: 'localhost',
    port: 7474,
    path: '/db/data/transaction',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'charset': 'UTF-8'
    }
  };

function postWord (wordName, language, callback) {
  var postReq = http.request(postOptions, function (res) {
    res.pipe(bl(function (err, data) {
      console.log('posting node for ', wordName + ' ' + language);
    }));
  });

  var wordQuery = 'MERGE (' + wordName + ':Word { wordName:' + wordName + ', language:' + language + '})';

  var wordReq = {
    'statements': [{
      'statement': wordQuery
    }]
  };

  postReq.write(JSON.stringify(wordReq));
  postReq.end();
}

//function getOptions (wordName, language) {
  //var options = {
      //hostname: 'localhost',
      //port: 7474,
      //path: '/db/data/label/Word/nodes?wordName="' + wordName + '"?language="' + language + '"',
      //method: 'GET',
      //headers: {
        //'Content-Type': 'application/json',
        //'charset': 'UTF-8'
      //}
    //};
  
  //return options;
//}

// Get a word's json and pass it to checker func
// ----------------------------------------
//function getWordData (record, callback) {
  //var word1 = record.word1;
  //var lang1 = record.lang1_iso3;
  //var word2 = record.word2;
  //var lang2 = record.lang2_iso3;
  //var getOpts1 = getOptions(word1, lang1);
  //var getOpts2 = getOptions(word2, lang2);

  //http.get(getOpts1, function (res1) {
    //http.get(getOpts2, function (res2) {
      //res1.pipe(bl(function (err, data1) {
        //res2.pipe(bl(function (err, data2) {
          //console.log('res');
          //callback(record, data1.toString(), data2.toString());
        //}));
      //}));
    //});
  //});
//}

function relation (word1, lang1, word2, lang2) {
  console.log(word2 + ' ORIGIN_OF -> ' + word1);
  var postRel = http.request(postOptions, function (res) {
    res.on('data', function (chunk) {
      console.log('BODY ', chunk);
    });
  });

  var matchQuery = 'MATCH (' + word1 + ':Word { wordName:' + word1 + ', language:' + lang1 + '}),' + 
    '(' + word2 + ':Word { wordName:' + word2 + ', language:' + lang2 + '})';

  var relQuery = [
    matchQuery,
    'MERGE (' + word2 + ')-[r:ORIGIN_OF]->(' + word1 + ')',
    'RETURN r'
  ].join('\n');

  var relReq = {
    'statements': [{
      'statement': relQuery
    }]
  };

  postRel.write(JSON.stringify(relReq));
  postRel.end();
}

function processNode (record) {
  // parse word data
  console.log('parsing...');
  var word1 = record.word1;
  var word2 = record.word2;
  
  async.parallel({    
    check1: function (callback) {
      postWord(record.word1, record.lang1_iso3, callback);
    },
    check2: function (callback) {
      postWord(record.word2, record.lang2_iso3, callback);
    }
  },
  function (err, result) {
    // now data for both words is guaranteed; check relationships
    relation(record.word1, record.lang1_iso3, record.word2, record.lang2_iso3);
  });
}

//var eg = {
  //lang1_name: 'Breton',
  //lang2_name: 'Latin',
  //word1: 'hello',
  //word2: 'Coltrane',
  //lang1_iso3: 'eng',
  //lang2_iso3: 'lat' 
//};

//getWordData(eg, processNode);

// import csv
var csvPath = process.cwd() + path.resolve(__filename, '/data/output/small.csv');

var parser = csv().from.stream(fs.createReadStream(csvPath), { columns: true });
parser.on('record', function (record) {
  processNode(record);
});

