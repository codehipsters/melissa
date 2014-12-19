Q = require 'q'
_ = require 'lodash'

parseCoordinates = require './utils/parseCoordinates'
TreasureMap      = require './TreasureMap'

class Contest
  constructor: (@vkAPIClient, postLink) ->
    @vk = Q.nbind(vkAPIClient.api, vkAPIClient)
    [ @ownerId, @postId ] = postLink.split('_')

  start: (options) ->
    @map = new TreasureMap(options.width, options.height)
    @map.hideTreasures(options.treasures, options.seed)

    @bids = {}


  ###
  # Private
  ###
  getContenders: ->
    console.log @ownerId, @postId
    @vk('wall.getReposts', { owner_id: @ownerId, post_id: @postId, count: 1000 })
    .then (result) ->
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

        # Среди тех человек, которые попали на одну точку, выделяем тех,
        # кто сделал это первым
        .groupBy (entry) ->
          entry.coords.join('-')
        .mapValues (entries) ->
          _.first(_.sortBy entries, (e) -> parseInt(e.repost.date))
        .values()
      .value()

      console.log contenders


  watchRoutine: ->
    @getContenders().then (res) ->
      console.log res

module.exports = Contest