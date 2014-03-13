$ = require 'jquery'
require 'select2'

wordUrl = 'http://localhost:3000/word'

$('#word-selector').select2({
  placeholder: 'Search for a word'
  minimumInputLength: 1
  ajax:
    dataType: 'json'
    url: wordUrl
    data: (term, page) ->
      query =
        q: term
      return query
    results: (data, page) ->
      return {results: data[0]}
})
