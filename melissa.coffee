vkAPI  = require 'vk-api'
_      = require 'lodash'
Q      = require 'q'

config = require './config.json'
parseCoordinates = require './app/utils/parseCoordinates'

vkAPIClient = new vkAPI
  appID:     config.appId
  appSecret: config.appSecret

vk = Q.nbind(vkAPIClient.api, vkAPIClient)

vk('wall.getReposts', { owner_id:  -60684683, post_id: 663, count: 1000 })
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

  console.log _.map(contenders, (e) -> e.coords.join('-') + ' ' + e.repost.text)



