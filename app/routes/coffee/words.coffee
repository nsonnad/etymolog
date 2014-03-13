neo4j = require 'neo4j'
_ = require 'lodash'

transformWordData = require './transformWordData'

db = new neo4j.GraphDatabase(
  process.env['NEO4J_URL'] or
  process.env['GRAPHENDB_URL'] or
  'http://localhost:7474'
)

getWordById = (req, res) ->
  id = req.params.id
  db.getNodeById id, (err, node) ->
    if err then console.error err
    res.send node

getEtym = (req, res) ->
  id = req.params.id

  query = [
    "start a=node(#{id})"
    "match p=(a)-[r:ORIGIN_OF*1..3]-(b)"
    "where not b-->()"
    "with extract(rel in rels(p) | {
      origin: {
        id: ID(startnode(rel)),
        word: startnode(rel).word
      },
      target: {
        id: ID(endnode(rel)),
        word: endnode(rel).word
      }
    }) as wordData"
    "return collect(distinct wordData) as words"
  ].join('\n')

  params =
    id: id

  db.query query, params, (err, results) ->
    if err then console.error err
    flat = _.flatten(results[0].words)
    res.send flat

getNodeByWord = (req, res) ->
  q = req.query.q
  console.log q
  query = [
    "match (n:Word) where n.word =~ {word}"
    "return {id: ID(n), wordName: n.word, lang: n.lang_name} as word"
  ].join('\n')

  # semi-fuzzy search
  params =
    word: "(?i)#{q}.*"

  db.query query, params, (err, results) ->
    if err then console.error err
    res.send results

module.exports =
  getWordById: getWordById
  getEtym: getEtym
  getNodeByWord: getNodeByWord
