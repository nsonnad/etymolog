exports.index = (req, res) ->
  res.render 'index',
    title: "etymolog"

exports.words = require './words'
