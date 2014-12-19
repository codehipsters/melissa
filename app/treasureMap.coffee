_ = require 'lodash'
Stochator = require 'stochator'

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


    x = { kind: 'integer', min: 0, max: @width,  seed: seed}
    y = { kind: 'integer', min: 0, max: @height, seed: seed}
    randomPoint = new Stochator(x, y)

    @treasures = {}
    for kind in kinds
      [ x, y ] = [ 0, 0 ]

      key = false

      while !key or @treasures[ key ]
        [x, y] = randomPoint.next()
        key = @keyFor(x, y)

      @treasures[ key ] = { kind }
    @treasures

module.exports = TreasureMap