neo4j = require 'neo4j'
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

getWordTraversal = (req, res) ->
  id = req.params.id

  query = [
    "start a=node(#{id})"
    "match p=(a)-[r:ORIGIN_OF*1..3]-(b)"
    "where not b-->()"
    "with {
      word: a.word,
      path: collect(extract(n in relationships(p) |
        {
          target: n.target,
          origin: n.origin
        }
      ))
    } as wordData"
    "return distinct wordData"
  ].join('\n')

  params =
    id: id

  db.query query, params, (err, results) ->
    if err then console.error err
    console.log results[0].wordData.path.length
    res.send results

_getIdByName = (req, res) ->
  name = req.params.name
  query = [
    "match (n:Word) where n.word={word}"
    "return ID(n) as id"
  ].join('\n')

  params =
    word: name

  db.query query, params, (err, results) ->
    if err then console.error err
    console.log results.length
    res.send results

module.exports =
  getWordById: getWordById
  getWordTraversal: getWordTraversal
  _getIdByName: _getIdByName
