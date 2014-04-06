# Autocomplete select box
$ = require 'jquery'
require 'select2'
getEtymById = require('./drawNodes').getEtymById

wordUrl = '/_word'

formatWordResult = (wordData) ->
  "<p>#{wordData.word.wordName} - #{wordData.word.lang}</p>"

formatWordSelection = (wordData) ->
  "#{wordData.word.wordName} - #{wordData.word.lang}"

# fetch words from db
$('#word-selector').select2
    placeholder: 'Search for a word'
    minimumInputLength: 2
    id: (e) -> e.word.id
    ajax:
      dataType: 'json'
      url: wordUrl
      data: (term, page) ->
        return { q: term }
      results: (data, page) ->
        return { results: data }
    initSelection: (el, cb) ->
      id = $(el).val()
      console.log id
      $.ajax('/_id', {
        data: { q: id }
        dataType: 'json'
      }).done((data) -> console.log data; cb(data[0]))
    formatResult: formatWordResult
    formatSelection: formatWordSelection
    dropdownCssClass: 'bigDrop'
    escapeMarkup: (m) -> m

$('#word-selector').on 'change', (e) ->
    e.preventDefault()
    getEtymById e.val

# make sure back button works
popped = ('state' in window.history)
initialURL = location.href
$(window).bind 'popstate', (event) ->
  initialPop = !popped && location.href == initialURL
  popped = true
  if initialPop
    return
  else
    newId = event.originalEvent.state
    $('#word-selector').select2 'val', newId
    getEtymById newId
