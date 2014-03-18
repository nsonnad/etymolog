d3 = require 'd3'

module.exports = (wordData) ->
  ###
  wordData object contains 'rels' key and 'nodes' key.
  'nodes' contains unique list of all words related to chosen word
  'rels' contains ids of the relevant origin and target nodes
  ###
  console.log wordData
