d3 = require 'd3'

margin = { t: 20, r: 20, b: 20, l: 20 }
initWidth = 900
initHeight = 700
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

showPath = (d) ->
  paths = d.pathId
  paths = if paths.length > 1 then paths.join("'],[data-path='") else paths[0]
  selector = ".node-link[data-path='#{paths}']"

  d3.selectAll selector
    .classed 'active', true

unshowPath = () ->
  d3.selectAll '.node-link'
    .classed 'active', false

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
    hashLookup[d.source].pathId.push d.pathId.toString()
    hashLookup[d.target].pathId.push d.pathId.toString()
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
    .on 'mouseover', showPath
    .on 'mouseout', unshowPath
    .call force.drag

  circles = nodeG.append 'circle'
    .attr
      class: 'node-circle'
      r: 6

  nodeG.append 'svg:title'
    .text (d) -> d.word

  linkLines = links.enter().append 'path'
    .attr
      class: 'node-link'
      'data-path': (d) -> d.pathId.toString()

  tick = () ->
    nodeG.attr
      transform: (d) -> "translate(#{[d.x, d.y]})"

    linkLines.attr
      d: linkArc

  force
    .on 'tick', tick
    .size [w, h]
    .start()

  return

updateDimensions()

linkArc = (d) ->
  dx = d.target.x - d.source.x
  dy = d.target.y - d.source.y
  dr = Math.sqrt(dx * dx + dy * dy) / 1.5
  "M#{d.source.x},#{d.source.y}A#{dr},#{dr} 0 0,1#{d.target.x},#{d.target.y}"

module.exports =
  applyEtymData: applyEtymData
  updateDimensions: updateDimensions
