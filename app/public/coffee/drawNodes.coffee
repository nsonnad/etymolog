d3 = require 'd3'

module.exports = (data) ->
  nested = d3.nest()
    .key((d) -> d.origin.id)
    .entries(data)

  console.log nested
