d3 = require 'd3'

applyEtymData = (wordData) ->
  ###
  wordData object contains 'rels' key and 'nodes' key.
  'nodes' contains unique list of all words related to chosen word
  'rels' contains ids of the relevant origin and target nodes
  ###
  console.log wordData

module.exports =
  applyEtymData: applyEtymData
