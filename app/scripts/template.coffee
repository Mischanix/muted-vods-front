$ = require 'jquery'
moment = require 'moment'
rivets = require 'rivets'

rivets.binders.link = (el, value) ->
  el.href = value

rivets.binders.progress = (el, value) ->
  el.style.width = "#{value * 100}%"

rivets.binders.sortvalue = (el, value) ->
  el.setAttribute 'data-value', value

rivets.formatters.date = (value) -> moment(value).format('YYYY-MM-DD HH:mm')
rivets.formatters.minutes = (value) -> Math.round value / 60
rivets.formatters.percent = (value) -> "#{Math.round(1000 * value) / 10}%"

Array.prototype.clear = ->
  @pop() while @length > 0

templates = {}
bind = (el, template, data) ->
  if typeof el is 'string'
    data = template
    template = el
    rivets.bind $("[binds-to=#{template}]"), data
  else
    el = el[0] if el[0]?
    text = templates[template]
    if not text?
      text = $("script[binds-to=#{template}]")[0].innerHTML
      templates[template] = text
    el.innerHTML = text
    rivets.bind el, data

module.exports = { bind }
