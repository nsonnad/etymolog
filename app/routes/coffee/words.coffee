neo4j = require 'neo4j'
db = new neo4j.GraphDatabase(
  process.env['NEO4J_URL'] or
  process.env['GRAPHENDB_URL'] or
  'http://localhost:7474'
)

exports.getWordById = (req, res) ->
  id = req.params.id
  db.getNodeById id, (err, node) ->
    if err then console.error err
    res.send node

exports.getWordTraversal = (req, res) ->
  id = req.params.id

  query = [
    "start a=node(#{id})"
    "match p=(a)-[r:ORIGIN_OF*1..3]-(b)"
    #"where not b-->()"
    #"return b.word, collect(distinct extract(n in nodes(p) | n.word))"
    "return
      { word: a.word,
        id: ID(a),
        targets: extract(n in relationships(p) | n.target),
        origins: extract(n in relationships(p) | n.origin),
        originID: extract(n in relationships(p) | ID(n))
      }
    "
  ].join('\n')

  params =
    id: id

  db.query query, params, (err, results) ->
    if err then console.error err
    console.log results.length
    res.send results

exports.getWordByName = (req, res) ->
  name = req.params.name
  query = [
    "match p=(a)-[r:ORIGIN_OF*1..2]-(b)"
    "where a.word={word}"
    #"where not b-->()"
    "return b.word"
    #"return {
      #origins: extract(n in relationships(p) | n.origin),
      #targets: extract(n in relationships(p) | n.target)
    #}"
  ].join('\n')

  params =
    word: name

  db.query query, params, (err, results) ->
    if err then console.error err
    console.log results.length
    res.send results
