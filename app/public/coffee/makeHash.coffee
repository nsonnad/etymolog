module.exports = (etymData) ->
  # create hash lookup to match links and nodes
  # adding in the path ids for highlighting
  hashLookup = {}

  etymData.nodes.forEach (d) ->
    hashLookup[d.id] = d

  etymData.rels.forEach (d) ->
    hashLookup[d.source].pathId.push d.pathId.toString()
    hashLookup[d.target].pathId.push d.pathId.toString()
    d.source = hashLookup[d.source]
    d.target = hashLookup[d.target]

  return hashLookup
