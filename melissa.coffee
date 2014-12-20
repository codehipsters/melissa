vkAPI  = require 'vk-api'
_      = require 'lodash'
Q      = require 'q'

# Части приложения
Contest   = require './app/Contest'
Launchpad = require './app/Launchpad'

# Подгружаем конфигурацию из файла
config = require './config.json'

###
# Подготовка и запуск
###
vkAPIClient = new vkAPI
  appID:     config.appId
  appSecret: config.appSecret

contest = new Contest(vkAPIClient, config.post)

contest.start
  width:  8
  height: 8
  seed: config.seed
  treasures: [
    { kind: 'gold',   amount: 1 }
    { kind: 'silver', amount: 3 }
    { kind: 'bronze', amount: 10 }
  ]

###
# Вывод карту с сокровищами на консоль
###
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

    line.unshift(y + 1)
    console.log line.join(' ')
printMap(contest.map)

###
# Подключаем лаунчпад
###
launchpad = new Launchpad
launchpad.on 'ready', ->
  launchpad.redraw()

contest.on 'update', (elems, diff) ->
  launchpad.redraw(elems)

  winners =  _(diff).filter (e) -> e.treasure
  if winners.length > 0
    launchpad.blinkHeart()

  console.log '❤ Появилось обновление:'
  _(diff).sortBy (e) -> e.treasure?.kind
  .each (w, i) ->
    console.log "  [#{w.coords}] [#{w.treasure?.kind}] #{w.user.first_name} #{w.user.last_name} http://vk.com/id#{w.user.id}"







