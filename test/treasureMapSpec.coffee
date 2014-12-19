expect = require('chai').expect

TreasureMap = require '../app/treasureMap'
_ = require 'lodash'

describe 'TreasureMap', ->
  describe '#hideTreasures', ->
    it 'fails when the grid is not enough', ->
      map = new TreasureMap(3, 3)
      result = map.hideTreasures([
        { kind: 'small',  amount: 3 },
        { kind: 'medium', amount: 8 }
      ])

      expect( result ).to.not.be.ok()
      expect( map.treasures ).to.be.empty()

    it 'hides exact amount of each kind of a treasure', ->
      map = new TreasureMap(5, 5)
      _.each [1..100], ->
        meta = [
          { kind: 'little',  amount: 2 },
          { kind: 'small',   amount: 11 }
          { kind: 'medium',  amount: 7 },
          { kind: 'large',   amount: 5 }
        ]

        map.hideTreasures(meta)

        stats = _.countBy _(meta).values(), 'kind'

        _.each meta, (treasure) ->
          expect( stats[ treasure.kind ] ).to.eql treasure.amount

    it 'can use seed to produce equal results', ->
      map = new TreasureMap(100, 100)
      meta = [
        { kind: 'little',  amount: 2 },
        { kind: 'small',   amount: 11 }
        { kind: 'medium',  amount: 7 },
        { kind: 'large',   amount: 5 }
      ]

      seed = _.random(1, 1000)
      map.hideTreasures(meta, seed)
      lhs = map.treasures

      map.hideTreasures(meta, seed)
      rhs = map.treasures

      expect( lhs ).to.eql rhs


