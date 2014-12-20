midiLaunchpad = require 'midi-launchpad'
_ = require 'lodash'

{ EventEmitter } = require 'events'

class Launchpad extends EventEmitter
  HEART_BYTES = [
    "        ",
    " rr  rr ",
    "rrrrrrrr",
    "rrrrrrrr",
    " rrrrrr ",
    "  rrrr  ",
    "   rr   ",
    "        "
  ]

  renderTranslatedBytes: (bytes) ->
    translated = _.map [0...8], (y) ->
      line = _.map [0...8], (x) ->
        bytes[7 - x][y]

      line.join('')


    @launchpad?.renderBytes(translated)

  constructor: ->
    try
      midiConnector = midiLaunchpad.connect(0)
      midiConnector.on "ready", (launchpad) =>
        @launchpad = launchpad
        @emit 'ready'
    catch e
      console.log 'Проблема с лаунчпадом', e

  redraw: (field) ->
    if field
      @pixels = _.map [0...8], (y) ->
        line = _.map [0...8], (x) ->
          g = _.find field, (c) ->
            c.coords[0] is x and c.coords[1] is y

          return ' ' unless g
          return 'r' unless g.treasure

          switch g.treasure.kind
            when 'gold'   then 'y'
            when 'silver' then 'y'
            when 'bronze' then 'g'
            else 'g'

        line.join('')

    if @pixels
      @launchpad?.clear()
      @renderTranslatedBytes(@pixels)

  blinkHeart: ->
    i = 0

    blinkRoutine = =>
      @launchpad?.clear()
      if i % 2 is 0
        @renderTranslatedBytes(HEART_BYTES)

      if i++ < 5
        setTimeout(blinkRoutine, 500)
      else
        @redraw()

    do blinkRoutine


module.exports = Launchpad