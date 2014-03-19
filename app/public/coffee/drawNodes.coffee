d3 = require 'd3'

margin = { t: 20, r: 20, b: 20, l: 20 }
initWidth = 900
initHeight = 500
etymNodes = []
etymLinks = []

force = d3.layout.force()
  .nodes etymNodes
  .links etymLinks
  .linkDistance 50
  .charge -100

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

  # create hash lookup to match links and nodes
  hashLookup = {}

  etymData.nodes.forEach (d) ->
    hashLookup[d.id] = d

  etymData.rels.forEach (d) ->
    d.source = hashLookup[d.source]
    d.target = hashLookup[d.target]

  force
    .nodes d3.values hashLookup
    .links etymData.rels

  linksG = svgG.append('g').attr('class', 'links-g')
  nodesG = svgG.append('g').attr('class', 'nodes-g')

  svgG.selectAll('.node-link').remove()
  svgG.selectAll('.node-g').remove()
  
  nodes = nodesG.selectAll '.node-g'
    .data force.nodes(), (d) -> d.id

  links = linksG.selectAll '.node-link'
    .data force.links(), (d) -> d.source.id + '-' + d.target.id

  nodeG = nodes.enter().append 'g'
    .attr
      class: 'node-g'
    .call force.drag

  circles = nodeG.append 'circle'
    .attr
      class: 'node-circle'
      r: 6

  linkLines = links.enter().append 'line'
    .attr
      class: 'node-link'

  tick = () ->
    nodeG.attr
      transform: (d) -> "translate(#{[d.x, d.y]})"

    linkLines.attr
      x1: (d) -> d.source.x
      y1: (d) -> d.source.y
      x2: (d) -> d.target.x
      y2: (d) -> d.target.y

  force
    .on 'tick', tick
    .size [w, h]
    .start()

  return

updateDimensions()

module.exports =
  applyEtymData: applyEtymData
  updateDimensions: updateDimensions
