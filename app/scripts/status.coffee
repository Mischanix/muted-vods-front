$ = require 'jquery'
require '../../bower_components/bootstrap-sortable/Scripts/bootstrap-sortable.js'
{ bind } = require './template'
api = require './api'

model = {
  channel: ''
  age: 0
  refreshable: false
  permalink: ''
  finished: false
  results: false
  # loading indicators:
  progress: {
    show: false
    phase_one: false
    phase_two: false
    datas: 0
    ids: 0
    current: 0
    total: 0
  }
  # type-specific:
  summary: {
    lines: []
    unprocessed: 0
    unmuted: 0
    muted: 0
  }
  hasVideos: false
  videos: []
  # type selector:
  mode: {
    broadcasts: true
    highlights: false
  }
  status: {}
  refresh: (e) ->
    api.refresh model.channel, handle
    check model.channel
    !!e.preventDefault()
  modeBroadcasts: (e) ->
    setMode 'broadcasts'
    !!e.preventDefault()
  modeHighlights: (e) ->
    setMode 'highlights'
    !!e.preventDefault()
}
$results = ($ '#results')[0]
view = bind $results, 'status', model
statusInterval = -1

setMode = (mode) ->
  model.mode.broadcasts = false
  model.mode.highlights = false
  model.mode[mode] = true
  renderTab model.status

handle = (status) ->
  model.status = status
  if status.finished
    clearInterval statusInterval
    statusInterval = -1

  model.channel = status.channel
  model.error = status.error
  model.age = (Date.now() - status.started) / 1000
  model.refreshable = model.age > 50 * 60
  model.permalink = '/' + status.channel
  model.finished = status.finished
  model.progress.phase_zero = false
  model.progress.phase_one = false
  model.progress.phase_two = false
  if status.progress and not status.finished
    model.progress.show = true
    model.progress.datas = (status.progress.current_datas or 0) / status.progress.total_vods
    model.progress.ids = status.progress.current_ids / status.progress.total_vods - model.progress.datas
    model.progress.total = status.progress.total_vods
    if not status.progress.current_datas?
      model.progress.phase_one = true
      model.progress.current = status.progress.current_ids
    else
      model.progress.phase_two = true
      model.progress.current = status.progress.current_datas
  else
    if not status.finished
      model.progress.phase_zero = true
    model.progress.show = false

  renderTab status
  null

renderTab = (status) ->
  tabtype = if model.mode.broadcasts then status.broadcasts else status.highlights
  if tabtype?.summary
    model.results = true
    total = tabtype.summary.total_seconds
    unprocessed = tabtype.summary.unprocessed_seconds
    muted = tabtype.summary.muted_seconds
    unmuted = total - unprocessed - muted
    model.summary.unprocessed = unprocessed / total
    model.summary.unmuted = unmuted / total
    model.summary.muted = muted / total
    model.summary.lines.clear()
    for o in [
        [unprocessed, 'not yet processed'],
        [unmuted, 'not muted'],
        [muted, 'muted']]
      model.summary.lines.push {
        duration: o[0]
        name: o[1]
        percent: o[0] / total
      }
    model.videos.clear()
    for id, video of tabtype.affected
      model.videos.push {
        link: video.url
        title: video.title
        recorded: video.recorded
        views: video.views
        total: video.total_seconds
        muted: video.muted_seconds
        percent: video.muted_seconds / video.total_seconds
      }
    model.hasVideos = !!model.videos.length
    $.bootstrapSortable true
  else
    model.hasVideos = false
    model.results = false
  null

check = (name) ->
  name = name.substr 1 + name.lastIndexOf '/'
  name = name.trim().toLowerCase()
  clearInterval statusInterval if statusInterval isnt -1
  statusInterval = setInterval (->
    api.status name, handle
  ), 1000

do ->
  hashVal = (location.hash.substr 1).trim()
  if hashVal isnt ''
    (require './channel').set 'name', hashVal
    check hashVal

module.exports = { handle, check }
