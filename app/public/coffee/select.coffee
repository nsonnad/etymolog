$ = require 'jquery'
require 'select2'
applyEtymData = require('./drawNodes').applyEtymData

wordUrl = '/_word'
currUrl = window.location.pathname
history.pushState { path: window.location.href}, ''
m = currUrl.match /\/word\/(\d+)$/

getEtymById = (id) ->
  $.ajax
    url: '/_etym/' + id
    success: (data) ->
      if m
        newUrl = id.toString()
      else
        newUrl = "word/#{id.toString()}"
      history.pushState(id, data.nodes[0].word, newUrl)
      applyEtymData data
    dataType: 'json'

updateSelect = (newId) ->
  $('#word-selector').val(newId)
  getEtymById newId

if m
  updateSelect(m[1])

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

popped = ('state' in window.history)
initialURL = location.href
$(window).bind 'popstate', (event) ->
  initialPop = !popped && location.href == initialURL
  popped = true
  if initialPop
    return
  else
    newId = event.originalEvent.state
    $ '#word-selector'
      .select2('val', newId)

    getEtymById newId
