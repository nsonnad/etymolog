neo4j = require 'neo4j'
db = new neo4j.GraphDatabase(
  process.env['NEO4J_URL'] or
  process.env['GRAPHENDB_URL'] or
  'http://localhost:7474'
)

exports.getWordById = (req, res) ->
  console.log 'getting id...'
  id = req.params.id
  db.getNodeById id, (err, node) ->
    if err then console.error err
    console.log node._data.properties
    res.send node

exports.getWordTraversal = (req, res) ->
  console.log 'getting id...'
  id = req.params.id
  query = [
    "START a=node(#{id})"
    "MATCH p=a-[r*]->x"
    "WHERE NOT(x-->())"
    "RETURN a,x"
  ].join('\n')
  params =
    id: id

  db.query query, params, (err, results) ->
    if err then console.error err
    res.send results
