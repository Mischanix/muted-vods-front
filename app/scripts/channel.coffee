channel = {
  name: ''
  checkable: true
  check: (e) ->
    (require './status').check channel.name
    e.preventDefault()
    false
}
(require './template').bind 'channel', channel

set = (prop, val) ->
  channel[prop] = val

get = (prop) ->
  channel[prop]

module.exports = { set, get }
