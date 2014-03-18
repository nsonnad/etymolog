neo4j = require 'neo4j'
_ = require 'lodash'

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
    "return collect(distinct extract(rel in rels(p) | {
      originId: ID(startnode(rel)),
      targetId: ID(endnode(rel))
    })) as rels, collect(distinct extract(n in nodes(p) | {
      id: ID(n),
      word: n.word,
      lang: n.lang_name
    })) as nodes"
  ].join('\n')

  params =
    id: id

  db.query query, params, (err, results) ->
    if err then console.error err
    rels = _.flatten(results[0].rels)
    nodes = _.flatten(results[0].nodes)

    response =
      rels: rels
      nodes: nodes

    res.send response

getNodeByWord = (req, res) ->
  q = req.query.q
  console.log q
  query = [
    "match (n:Word) where n.word =~ {word}"
    "return {id: ID(n), wordName: n.word, lang: n.lang_name} as word"
    "order by lower(n.word)"
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
