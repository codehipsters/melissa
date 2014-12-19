Q = require 'q'
_ = require 'lodash'

parseCoordinates = require './utils/parseCoordinates'
TreasureMap      = require './TreasureMap'

WATCH_INTERVAL = 60 * 1000

class Contest
  constructor: (@vkAPIClient, postLink) ->
    @vk = Q.nbind(vkAPIClient.api, vkAPIClient)
    [ @ownerId, @postId ] = postLink.split('_')

  start: (options) ->
    @map = new TreasureMap(options.width, options.height)
    @map.hideTreasures(options.treasures, options.seed)

    @bids = {}
    do @watchRoutine

  rememberUserChoice: (userId, coords) ->
    @bids[ userId ] = coords.join(':')

  hasAlreadyMadeAnotherChoice: (userId, coords) ->
    bid = @bids[ userId ]
    bid? and bid isnt coords.join(':')

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
          entry.coords.join('-')
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

  watchRoutine: ->
    @getContenders()
    .then (data) =>
      console.log data
    .catch (err) =>
      console.log err
    .fin =>
      setTimeout @watchRoutine.bind(@), WATCH_INTERVAL


module.exports = Contest