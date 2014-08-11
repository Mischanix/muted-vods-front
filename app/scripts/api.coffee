$ = require 'jquery'

get = (url, cb) ->
  $.getJSON 'http://mutedvods.com' + url, cb

status = (channel, cb) ->
  get '/status/' + channel, cb

refresh = (channel, cb) ->
  get '/refresh/' + channel, cb

module.exports = { status, refresh }
