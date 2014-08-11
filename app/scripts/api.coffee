$ = require 'jquery'

get = (url, cb) ->
  $.getJSON 'http://localhost:8080' + url, cb

status = (channel, cb) ->
  get '/status/' + channel, cb

refresh = (channel, cb) ->
  get '/refresh/' + channel, cb

module.exports = { status, refresh }
