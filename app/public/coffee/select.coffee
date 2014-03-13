$ = require 'jquery'
require 'select2'

wordUrl = 'http://localhost:3000/word'

formatWordResult = (wordData) ->
  "<p>#{wordData.word.wordName} - #{wordData.word.lang}</p>"

#formatWordSelection = (word) ->
  #return word.wordName

$('#word-selector').select2({
  placeholder: 'Search for a word'
  minimumInputLength: 2
  ajax:
    dataType: 'json'
    url: wordUrl
    data: (term, page) ->
      return {q: term}
    results: (data, page) ->
      return {results: data}
  formatResult: formatWordResult
  #formatSelection: formatWordSelection
})
