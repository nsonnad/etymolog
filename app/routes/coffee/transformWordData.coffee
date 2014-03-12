_ = require 'lodash'

module.exports = (dbRes) ->
  flat = _.flatten(dbRes[0].words)

  return flat

