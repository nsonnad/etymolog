neo4j = require('neo4j')
flatten = require('lodash').flatten
uniq = require('lodash').uniq

dbUrl = process.env['GRAPHENEDB_URL'] || 'http://localhost:7474'

db = new neo4j.GraphDatabase(dbUrl)

getWordById = (req, res) ->
  id = req.query.q

  query = [
    "start n=node(#{id})"
    "return {id: ID(n), wordName: n.word, lang: n.lang_name} as word"
  ].join('\n')
  
  params =
    id: id

  db.query query, params, (err, node) ->
    if err then console.error err
    res.send node

getNodeByWord = (req, res) ->
  q = req.query.q
  query = [
    "match (n:Word) where n.word =~ {word}"
    "return {
      id: ID(n),
      wordName: n.word,
      lang: n.lang_name
    } as word"
    "order by lower(n.word)"
  ].join('\n')

  # semi-fuzzy search
  params =
    word: "(?i)#{q}.{0,3}"

  db.query query, params, (err, results) ->
    if err then console.error err
    res.send results

getEtym = (req, res) ->
  id = req.params.id
  params = { id: id }
  depth = 4
  minDepth = 2
  
  variableQuery = (dpth) ->
    query = [
      "match p=(a:Word)-[r:ORIGIN_OF*0..#{dpth}]-(b)"
      "where id(a)=#{id} and not b-->()"
      "return collect(extract(rel in rels(p) | {
        source: ID(startnode(rel)),
        target: ID(endnode(rel)),
        pathId: ID(rel)
      })) as rels, collect(extract(n in nodes(p) | {
        id: ID(n),
        word: n.word,
        lang: n.lang_name,
        pathId: []
      })) as nodes"
    ].join('\n')

    db.query query, params, (err, results) ->
      if err then console.error err
      rels = flatten(results[0].rels)
      nodes = flatten(results[0].nodes)
      if nodes.length < 2000 or depth is minDepth
        response =
          rels: rels
          nodes: nodes
        res.send response
      else
        depth--
        variableQuery(depth)

  variableQuery(depth)

module.exports =
  getWordById: getWordById
  getEtym: getEtym
  getNodeByWord: getNodeByWord
