require 'net/http'
require 'json'

res = []
ARGV.each do |arg|  
  user = Net::HTTP.get(URI.parse('https://gasyuku-api.herokuapp.com/users/' + arg))
  user = JSON.parse(user)
  user['subscribed_shop_ids'].each do |id|
    b = Net::HTTP.get(URI.parse('https://gasyuku-api.herokuapp.com/shops/' + id.to_s))
    if user['shops'] == nil
      user['shops'] = []
    end
    user['shops'].push(JSON.parse(b))
  end
  res << user
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
