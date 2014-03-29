$ = require 'jquery'
require 'select2'
applyEtymData = require('./drawNodes').applyEtymData

wordUrl = '/_word'
currUrl = window.location.pathname
history.replaceState { path: window.location.href}, ''

getEtymById = (id) ->
  $.ajax
    url: '/_etym/' + id
    success: (data) -> applyEtymData data
    dataType: 'json'

if currUrl.length > 1
  m = currUrl.match /\/word\/(\d+)$/
  if m
    id = m[1]
    $('#word-selector').val(id)
    getEtymById id

formatWordResult = (wordData) ->
  "<p>#{wordData.word.wordName} - #{wordData.word.lang}</p>"

formatWordSelection = (wordData) ->
  "#{wordData.word.wordName} - #{wordData.word.lang}"

$ '#word-selector'
  .select2
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
      $.ajax('/_id', {
        data: { q: id }
        dataType: 'json'
      }).done((data) -> cb(data[0]))
    formatResult: formatWordResult
    formatSelection: formatWordSelection
    dropdownCssClass: 'bigDrop'
    escapeMarkup: (m) -> m

$ '#word-selector'
  .on 'change', (e) ->
    e.preventDefault()
    getEtymById e.val
