_ = require 'lodash'

class TreasureMap
  constructor: (@width, @height) ->
    @treasures = {}

  square: ->
    @width * @height

  keyFor: (x, y) ->
    "#{x}:#{y}"

  hideTreasures: (treasuresMeta, seed) ->
    total = _.chain(treasuresMeta)
      .pluck 'amount'
      .reduce (x, y) -> x + y
      .value()

    return null if total > @square()

    kinds = _.chain(treasuresMeta)
      .map (meta) ->
        meta.kind for i in [0...meta.amount]
      .flatten()
      .value()

    @treasures = {}
    for kind in kinds
      [ x, y ] = [ 0, 0 ]

      key = false

      while !key or @treasures[ key ]
        x = _.random(0, @width)
        y = _.random(0, @height)
        key = @keyFor(x, y)

      @treasures[ key ] = { kind }
    @treasures

module.exports = TreasureMap