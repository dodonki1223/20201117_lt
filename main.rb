require 'net/http'
require 'json'

API_URL = 'https://gasyuku-api.herokuapp.com/'.freeze

res = ARGV.map do |arg|
  user = JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/users/#{arg}")), symbolize_names: true)
  user[:shops] = user[:subscribed_shop_ids].map do |id|
    JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/shops/#{id}")), symbolize_names: true)
  end
  user
end

puts JSON.dump(res)

# 実行例
# 
# ruby main.rb 1
# 
# [
#   {
#       "id": 1,
#       "name": "user1",
#       "subscribed_shop_ids": [
#           1,
#           2,
#           3,
#           4,
#           5,
#           6
#       ],
#       "shops": [
#           {
#               "id": "1",
#               "name": "Shop1"
#           },
#           {
#               "id": "2",
#               "name": "Shop2"
#           },
#           {
#               "id": "3",
#               "name": "Shop3"
#           },
#           {
#               "id": "4",
#               "name": "Shop4"
#           },
#           {
#               "id": "5",
#               "name": "Shop5"
#           },
#           {
#               "id": "6",
#               "name": "Shop6"
#           }
#       ]
#   }
# ]

# api例
# 
# curl https://gasyuku-api.herokuapp.com/users/1
# 
# {
#   "id":1,
#   "name":"user1",
#   "subscribed_shop_ids":[1,2,3,4,5,6]
# }

# curl https://gasyuku-api.herokuapp.com/shops/1
# 
# {
#   "id":"1",
#   "name":"Shop1"
# }
