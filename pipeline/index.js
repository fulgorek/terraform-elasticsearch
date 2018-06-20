'use strict';
var host            = process.env.HOST || false
const request       = require('request');
const elasticsearch = require('elasticsearch');
const Promise       = require('bluebird');
const csv           = require('fast-csv');

const log    = console.log.bind(console);
const client = new elasticsearch.Client({
  host: host + ':9200',
  // log: 'trace'
});

const path          = "./dataset/reddit-2018-wc-rosters.csv";
const options       = { 'headers': true };
const myindex       = "worldcup"

if (host === false){
  log("Error no host set as ENV var")
  return false;
}

function createIndex() {
  return new Promise(function(resolve, reject) {
    client.indices.create({index: myindex}, function (err, resp) {
      if (! err) {
        log('successfully created ElasticSearch index: %s', myindex);
      }
      resolve(resp)
    });
  })
}

function readDataSet() {
  return new Promise(function(resolve, reject) {
    var records = [];
    csv.fromPath(path, options)
      .on('data', function(record) {
        records.push(record);
      })
      .on('end', function() {
        resolve(records);
      });
  })
}

function bulkImport(records) {
  return new Promise(function(resolve) {
    var bulk_request = [];
    for (var i = 0; i < records.length; i++) {
      bulk_request.push({index: {_index: myindex, _type: 'player', _id: i + 1}});
      bulk_request.push(records[i]);
    }
    client.bulk({
      body: bulk_request
    }, resolve);
  });
}

function waitForIndexing() {
  log('Wait for indexing...');
  return new Promise(function(resolve) {
    setTimeout(resolve, 10000);
  });
}

function addToIndex() {
  log('creating index pattern on kibana for %s...', myindex)
  return new Promise(function(resolve) {
    request.post(
        'http://' + host + ':9200/.kibana/doc/index-pattern:' + myindex,
        { json: {"type": "index-pattern","index-pattern": {"title": myindex + "*", "timeFieldName": "" }} },
        function (error, response, body) {
          log(body)
          resolve(body);
        }
    );
  });
}

function closeConnection() {
  client.close();
}

function showInfo() {
  log("go to: http://%s:5601/app/kibana#/discover", host)
}

Promise.resolve()
  .then(createIndex)
  .then(addToIndex)
  .then(waitForIndexing)
  .then(readDataSet)
  .then(bulkImport)
  .then(closeConnection)
  .then(showInfo);
