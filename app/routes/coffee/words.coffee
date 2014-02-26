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
    console.log node._data.properties
    res.send node

exports.getWordTraversal = (req, res) ->
  id = req.params.id

  query = [
    "start a=node(#{id})"
    "match (a)-[r:ORIGIN_OF*1..2]-(b)"
    "with r as rels"
    "return rels"
  ].join('\n')

  params =
    id: id

  db.query query, params, (err, results) ->
    if err then console.error err
    console.log results.length
    res.send results
