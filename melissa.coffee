vkAPI  = require 'vk-api'
_      = require 'lodash'
Q      = require 'q'

# Части приложения
Contest   = require './app/Contest'
Launchpad = require './app/Launchpad'

# Подгружаем конфигурацию из файла
config = require './config.json'

###
# Инициализация
###
vkAPIClient = new vkAPI
  appID:     config.appId
  appSecret: config.appSecret

contest   = new Contest(vkAPIClient, config.post)
launchpad = new Launchpad

contest.on 'update', (elems, diff) ->
  launchpad.redraw(elems)

  if _.find(diff, (e) -> e.treasure)
    launchpad.blinkHeart()

  console.log 'YAARRRGH!'

launchpad.on 'ready', ->
  contest.start
    width:  8
    height: 8
    seed: 'es6meetup'
    treasures: [
      { kind: 'gold',   amount: 1 }
      { kind: 'silver', amount: 3 }
      { kind: 'bronze', amount: 10 }
    ]

  printMap = (map) ->
    symbols = { gold: '♛', silver: '★', bronze: '☆' }

    alphabet = [0...map.width].map (x) ->
      String.fromCharCode('a'.charCodeAt(0) + x)

    alphabet.unshift(' ')
    console.log alphabet.join(' ')

    for y in [0...map.height]
      line = _([0...map.width]).map (x) ->
        guess = map.guess(x, y)

        symbols[guess?.kind] ? '.'

      line.unshift(y+1)
      console.log line.join(' ')

  printMap(contest.map)




