# Fetch and visualize etymological data

$ = require 'jquery'
d3 = require 'd3'
require 'select2'
require './vendor/d3-tip/index.js'
makeHash = require './makeHash'

margin = { t: 20, r: 20, b: 20, l: 20 }
initWidth = 900
initHeight = 700
nodeRad = 7
graphDiv = document.getElementById('graph')

# check for a word id and update url
wordUrlMatch = window.location.pathname.match /\/word\/(\d+)$/
history.pushState { path: window.location.href }, ''

# fetch a word's etymologies
getEtymById = (id) ->
  $.ajax
    url: '/_etym/' + id
    success: (data) ->
      if wordUrlMatch
        newUrl = id.toString()
      else
        newUrl = "word/#{id.toString()}"

      currWord = data.nodes[0]
      history.pushState id, currWord.word, newUrl
      document.title = "etymolog | #{currWord.word}"
      $('#word-selector').select2 'val', id

      applyEtymData data
    dataType: 'json'

# update the select value and hit the server for data
if wordUrlMatch
  getEtymById wordUrlMatch[1]

# svg and d3 stuff
# ------------------------------------------------

force = d3.layout.force()
  .linkDistance 80
  .charge -60

svg = d3.select '#graph'
  .append 'svg'
  .attr
    width: initWidth
    height: initHeight

svgG = svg.append 'g'
  .attr
    transform: "translate(#{[margin.l, margin.t]})"

tooltip = d3.tip()
  .attr({ class: 'tooltip' })
  .offset [-nodeRad, 0]
  .html (d) ->
    "<h3>#{d.word} - <small>#{d.lang}</small></h3>"

linksG = svgG.append('g').attr('class', 'links-g')
nodesG = svgG.append('g').attr('class', 'nodes-g')

# some semblance of responsiveness
updateDimensions = () ->
  graphDiv = document.getElementById('graph')
  width = graphDiv.clientWidth
  height = width
  w = width - margin.l - margin.r
  h = height - margin.t - margin.b
  force.size [w, h]

  svg.attr
    width: w
    height: h

mouseOn = (d) ->
  tooltip.show(d)

  # highlight all paths coming in and out of current node
  paths = d.pathId
  currIndex = d.index
  paths = if paths.length > 1 then paths.join("'],[data-path='") else paths[0]
  selector = ".node-link[data-path='#{paths}']"

  d3.selectAll selector
    .each () ->
      # check whether current node is source or target
      d3node = d3.select this
      datum = d3node[0][0].__data__
      if datum.source.index is currIndex
        d3node.classed 'active-source', true
      else
        d3node.classed 'active-target', true

mouseOff = (d) ->
  tooltip.hide(d)
  d3.selectAll '.node-link'
    .classed 'active-source', false
    .classed 'active-target', false

###
wordData object contains 'rels' key and 'nodes' key.
'nodes' contains unique list of all words related to chosen word
'rels' contains ids of the relevant origin and target nodes
###
applyEtymData = (etymData) ->
  updateDimensions()

  force
    .nodes d3.values(makeHash(etymData))
    .links etymData.rels

  svgG.selectAll('.node-link').remove()
  svgG.selectAll('.node-g').remove()
  
  nodes = nodesG.selectAll '.node-g'
    .data force.nodes(), (d) -> d.id

  links = linksG.selectAll '.node-link'
    .data force.links(), (d) -> d.source.id + '-' + d.target.id

  nodeG = nodes.enter().append 'g'
    .attr
      class: 'node-g'
    .on 'mouseover', mouseOn
    .on 'mouseout', mouseOff
    .on 'click', (d) ->
      if d3.event.defaultPrevented || d.id == etymData.nodes[0].id
        return
      else
        tooltip.hide()
        getEtymById d.id

  circles = nodeG.append 'circle'
    .attr
      class: 'node-circle'
      r: nodeRad

  nodeZero = circles.filter (circle) -> circle.id == etymData.nodes[0].id
  nodeZero.classed 'node-zero', true

  linkG = links.enter().append 'g'
    .attr
      class: 'node-link'
      'data-path': (d) -> d.pathId.toString()

  linkLines = linkG.append 'path'

  # only move the dragged node, not the whole graph
  nodeG
    .call(d3.behavior.drag().origin((d) -> return d)
    .on 'drag', (d) ->
      tooltip.hide()
      d.x = d3.event.x
      d.y = d3.event.y
      d3.select this
        .attr
          transform: (d) -> "translate(#{[d.x, d.y]})"

      linkLines.filter (l) -> l.source is d
        .attr
          d: linkArc

      linkLines.filter (l) -> l.target is d
        .attr
          d: linkArc
  )

  tick = () ->
    nodeG.attr
      transform: (d) -> "translate(#{[d.x, d.y]})"

    linkLines.attr
      d: linkArc

  force
    .on 'tick', tick
    .start()

  for i in [50..0]
    force.tick()
  force.alpha(0.015)

svgG.call tooltip
updateDimensions()

# curved link paths
linkArc = (d) ->
  dx = d.target.x - d.source.x
  dy = d.target.y - d.source.y
  dr = Math.sqrt(dx * dx + dy * dy) / 1.5
  "M#{d.source.x},#{d.source.y}A#{dr},#{dr} 0 0,1#{d.target.x},#{d.target.y}"

module.exports =
  getEtymById: getEtymById
