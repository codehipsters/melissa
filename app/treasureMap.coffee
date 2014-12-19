class TreasureMap
  constructor: (@width, @height) ->
    @treasures = {}

  hideTreasures: (treasuresMeta, seed) ->
    false

module.exports = TreasureMap