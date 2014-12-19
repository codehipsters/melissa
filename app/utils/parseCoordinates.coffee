numberToCoord = (num) -> parseInt(num) - 1
letterToCoord = (letter) -> letter.charCodeAt(0) - 'a'.charCodeAt(0)

coordRegexp = ///
    (([a-zA-Z]{1}) [-_\s\.\:\;]{0,1} (\d+))
  | ((\d+)         [-_\s\.\:\;]{0,1} ([a-zA-Z]{1}))
///

module.exports = parseCoordinates = (str) ->
  match = coordRegexp.exec(str.toLowerCase())
  return null unless match

  if match[1]?
    [ _X, _Y ] = match[2..3]
  else
    [ _Y, _X ] = match[5..6]

  [ letterToCoord(_X), numberToCoord(_Y) ]



