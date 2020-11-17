res = []
ARGV.each do |arg|
  require 'net/http'
  a = Net::HTTP.get(URI.parse('https://gasyuku-api.herokuapp.com/users/' + arg))
  require 'json'
  a = JSON.parse(a)
  a['subscribed_shop_ids'].each do |id|
    b = Net::HTTP.get(URI.parse('https://gasyuku-api.herokuapp.com/shops/' + id.to_s))
    if a['shops'] == nil
      a['shops'] = []
    end
    a['shops'].push(JSON.parse(b))
  end
  res << a
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
