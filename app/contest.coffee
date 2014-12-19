Q = require 'q'
_ = require 'lodash'

{ EventEmitter } = require 'events'

parseCoordinates = require './utils/parseCoordinates'
TreasureMap      = require './TreasureMap'

WATCH_INTERVAL = 20 * 1000

flatCoords = (coords) ->
  coords.join(':')

###
# Класс представляет собой розыгрыш призов
###
class Contest extends EventEmitter
  constructor: (@vkAPIClient, postLink) ->
    @vk = Q.nbind(vkAPIClient.api, vkAPIClient)
    [ @ownerId, @postId ] = postLink.split('_')

  ###
  # Запуск отслеживания постов
  ###
  start: (options) ->
    @map = new TreasureMap(options.width, options.height)
    @map.hideTreasures(options.treasures, options.seed)

    @bids = {}
    @contenders = []
    do @watchRoutine

  ###
  # Функции для хранения информации о сделанных догадках
  ###
  rememberUserChoice: (userId, coords) ->
    @bids[ userId ] = flatCoords(coords)

  hasAlreadyMadeAnotherChoice: (userId, coords) ->
    bid = @bids[ userId ]
    bid? and bid isnt flatCoords(coords)

  ###
  # Private
  ###
  getContenders: ->
    @vk('wall.getReposts', { owner_id: @ownerId, post_id: @postId, count: 1000 })
    .then (result) =>
      reposts  = result.response.items
      profiles = result.response.profiles

      contenders = _.chain(reposts)
        # Берем только пользователей
        .filter (repost) ->
          repost.from_id > 0

        # Отображаем в удобный для нас формат, ищем соответствия
        # координатам и находим данные пользователя
        .map (repost) ->
          repost: repost
          user:   _(profiles).find(id: repost.from_id)
          coords: parseCoordinates(repost.text)

        # Исключаем нераспознанные координаты
        .reject (entry) ->
          _.isNull(entry.coords)

        # Исключаем координаты вне поля
        .select (entry) =>
          (0 <= entry.coords[0] < @map.width) and
          (0 <= entry.coords[1] < @map.height)

        # Среди тех человек, которые попали на одну точку, выделяем тех,
        # кто сделал это первым
        .groupBy (entry) ->
          flatCoords(entry.coords)
        .mapValues (entries) ->
          _.first(_.sortBy entries, (e) -> parseInt(e.repost.date))
        .values()

        # Убираем тех, кто уже когда-то делал выбор, но другой
        .reject (entry) =>
          @hasAlreadyMadeAnotherChoice(entry.user.id, entry.coords)

        # Запоминаем выбор пользователей
        .each (entry) =>
          @rememberUserChoice(entry.user.id, entry.coords)

      .value()

  # Вычитание одного множества ответов из другого
  diffContenders: (contendersA, contendersB) ->
    _(contendersA).foldl (diff, elem) =>
      oldElem = _(contendersB).find (e) ->
        flatCoords(e.coords) is flatCoords(elem.coords)

      if not oldElem or (elem.user.id isnt oldElem.user.id)
        diff.push(elem)

      diff
    , []

  # Обработка ответов, выделение разниц
  processContenders: (contenders) ->
    leftDiff  = @diffContenders(contenders,  @contenders)
    rightDiff = @diffContenders(@contenders, contenders)

    @contenders = contenders

    _(contenders).each (c) =>
      c.treasure = @map.guess(c.coords)

    if not _.isEmpty(leftDiff) or not _.isEmpty(rightDiff)
      @emit 'update', contenders, leftDiff

  watchRoutine: ->
    @getContenders()
    .then (data) =>
      @processContenders(data)
    .catch (err) =>
      console.log err
    .fin =>
      setTimeout @watchRoutine.bind(@), WATCH_INTERVAL


module.exports = Contest