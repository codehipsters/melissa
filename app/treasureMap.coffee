_ = require 'lodash'
Stochator = require 'stochator'

class TreasureMap
  constructor: (@width, @height) ->
    @treasures = {}

  square: ->
    @width * @height

  keyFor: (x, y) ->
    "#{x}:#{y}"

  guess: (x, y) ->
    if arguments.length is 1 and _.isArray(x)
      [ x, y ] = [ x[0], x[1] ]

    @treasures[ @keyFor(x, y) ]

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

    generator = new Stochator({ kind: 'integer', min: 0, max: @square() - 1,  seed: seed})

    @treasures = {}
    for kind in kinds
      [ x, y ] = [ 0, 0 ]

      key = false

      while !key or @treasures[ key ]
        point = generator.next()

        # Ищем остаток и делитель
        x = point % @width
        y = ((point - x) / @width) | 0

        key = @keyFor(x, y)

      @treasures[ key ] = { kind }
    @treasures

module.exports = TreasureMap