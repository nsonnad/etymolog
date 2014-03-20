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

svg.append 'defs'
  .append 'marker'
  .attr(
    id: 'arrowMarker'
    class: 'arrow-marker'
    viewBox: '0 -5 10 10'
    refX: 20
    refY: 1
    markerWidth: 5
    markerHeight: 5
    orient: 'auto'
  ).append 'path'
    .attr 'd', 'M0,-5L10,0L0,5'

updateDimensions = () ->
  graphDiv = document.getElementById('graph')
  width = graphDiv.clientWidth
  height = width
  w = width - margin.l - margin.r
  h = height - margin.t - margin.b
  force.size([w, h])

  svg.attr
    width: w
    height: h

showPath = (d) ->
  paths = d.pathId
  ix = d.index
  paths = if paths.length > 1 then paths.join("'],[data-path='") else paths[0]
  selector = ".node-link[data-path='#{paths}']"

  d3.selectAll selector
    .each () ->
      d3node = d3.select this
      datum = d3node.datum()
      if datum.source.index is ix
        d3node.classed 'active-source', true
      else
        d3node.classed 'active-target', true

unshowPath = () ->
  d3.selectAll '.node-link'
    .classed 'active-source', false
    .classed 'active-target', false

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
  # adding in the path ids for highlighting
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

  circles = nodeG.append 'circle'
    .attr
      class: 'node-circle'
      r: 7

  nodeG.append 'svg:title'
    .text (d) -> d.word

  d3.select circles[0][0]
    .classed 'node-zero', true

  linkG = links.enter().append 'g'
    .attr
      class: 'node-link'
      'data-path': (d) -> d.pathId.toString()

  linkLines = linkG.append 'path'
    #.attr
      #'marker-end': 'url(#arrowMarker)'

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
