expect = require('chai').expect

parseCoords = require '../app/utils/parseCoordinates'

describe 'utils', ->
  describe '#parseCoordinates', ->
    it 'parses trivial examples', ->
      expect( parseCoords('A1') ).to.eql [0, 1]
      expect( parseCoords('B3') ).to.eql [1, 3]
      expect( parseCoords('Z19') ).to.eql [25, 19]

    it 'returns null if parsing failed', ->
      expect( parseCoords('blabla') ).to.be.a 'null'
      expect( parseCoords('') ).to.be.a 'null'

    it 'matches case', ->
      expect( parseCoords('f22') ).to.eql [5, 22]
      expect( parseCoords('F2') ).to.eql [5, 2]

    it 'finds coordinates amoung other text', ->
      expect( parseCoords('So, here we are hoping B:4 to win') ).to.eql [1,4]

    it 'finds only first occurence', ->
      expect( parseCoords('a-12 hey hey ururu B12 ururu c4') ).to.eql [0,12]

    it 'can parse delimeted coordinates', ->
      expect( parseCoords('A 3') ).to.eql [0, 3]
      expect( parseCoords('B-7') ).to.eql [1, 7]
      expect( parseCoords('C:4') ).to.eql [2, 4]
      expect( parseCoords('A;3') ).to.eql [0, 3]

    it 'ignores the order', ->
      expect( parseCoords('3A') ).to.eql [0, 3]
      expect( parseCoords('10F') ).to.eql [5, 10]

