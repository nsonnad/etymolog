d3 = require 'd3'

margin = { t: 20, r: 20, b: 20, l: 20 }
initWidth = 900
initHeight = 500

force = d3.layout.force()

svg = d3.select '#graph'
  .append 'svg'
  .attr
    width: initWidth
    height: initHeight

svgG = svg.append 'g'
  .attr
    transform: "translate(#{[margin.l, margin.t]})"

updateDimensions = () ->
  graphDiv = document.getElementById('graph')
  width = graphDiv.clientWidth
  height = Math.min(500, Math.max(250, width / 1.5))
  w = width - margin.l - margin.r
  h = height - margin.t - margin.b
  force.size([w, h])

  svg.attr
    width: w
    height: h

applyEtymData = (etymData) ->
  ###
  wordData object contains 'rels' key and 'nodes' key.
  'nodes' contains unique list of all words related to chosen word
  'rels' contains ids of the relevant origin and target nodes
  ###
  graphDiv = document.getElementById('graph')
  width = graphDiv.clientWidth
  height = Math.min(500, Math.max(250, width / 1.5))
  w = width - margin.l - margin.r
  h = height - margin.t - margin.b

  force
    .nodes etymData.nodes
    .size [w, h]

  nodes = svgG.selectAll 'node-g'
    .data force.nodes()

  nodesG = nodes.enter().append 'g'
    .attr
      class: 'node-g'

  nodes.append 'circle'
    .attr
      r: 6
    .call force.drag

  tick = () ->
    nodesG.attr
      transform: (d) -> "translate(#{[d.x, d.y]})"

  force
    .on 'tick', tick
    .start()

  #rels = svgG.append('g').selectAll 'path'
    #.data force.links()
  #.enter().append 'path'
    #.attr
      #class: 'node-link'


  return

updateDimensions()

module.exports =
  applyEtymData: applyEtymData
  updateDimensions: updateDimensions
