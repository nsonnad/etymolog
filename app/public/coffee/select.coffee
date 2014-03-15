$ = require 'jquery'
require 'select2'

drawNodes = require './drawNodes'

wordUrl = '/word'

formatWordResult = (wordData) ->
  "<p>#{wordData.word.wordName} - #{wordData.word.lang}</p>"

formatWordSelection = (wordData) ->
  "#{wordData.word.wordName} - #{wordData.word.lang}"

$('#word-selector').select2({
  placeholder: 'Search for a word'
  minimumInputLength: 2
  id: (e) -> e.word.id
  ajax:
    dataType: 'json'
    url: wordUrl
    data: (term, page) ->
      return {q: term}
    results: (data, page) ->
      return {results: data}
  formatResult: formatWordResult
  formatSelection: formatWordSelection
  dropdownCssClass: 'bigDrop'
  escapeMarkup: (m) -> m
})

$('#word-selector').on 'change', (e) ->
  reqUrl = '/etym/' + e.val
  $.ajax({
    url: reqUrl
    success: (data) -> drawNodes data
    dataType: 'json'
  })
