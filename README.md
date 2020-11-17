# 2020年11月17日に行ったリファクタリングLTの内容

**APIの結果を出力するスクリプト** をチーム全員で簡単な修正を一人ずつ行っていく

## APIについて

#### users 

```
curl https://gasyuku-api.herokuapp.com/users/1

{
  "id":1,
  "name":"user1",
  "subscribed_shop_ids":[1,2,3,4,5,6]
}
```

#### shops

```
curl https://gasyuku-api.herokuapp.com/shops/1

{
  "id":"1",
  "name":"Shop1"
}
```

## APIの実行結果

#### 実行方法

```bash
$ ruby main.rb 1
```

#### 実行結果

```bash
[
  {
      "id": 1,
      "name": "user1",
      "subscribed_shop_ids": [
          1,
          2,
          3,
          4,
          5,
          6
      ],
      "shops": [
          {
              "id": "1",
              "name": "Shop1"
          },
          {
              "id": "2",
              "name": "Shop2"
          },
          {
              "id": "3",
              "name": "Shop3"
          },
          {
              "id": "4",
              "name": "Shop4"
          },
          {
              "id": "5",
              "name": "Shop5"
          },
          {
              "id": "6",
              "name": "Shop6"
          }
      ]
  }
]
```

## 実際のリファクタリング過程

コミットの履歴をここに記す

#### :recycle: requireを一番上に持ってくる

```ruby
require 'net/http'
require 'json'

res = []
ARGV.each do |arg|  
  a = Net::HTTP.get(URI.parse('https://gasyuku-api.herokuapp.com/users/' + arg))
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
```

#### :recycle: a の変数を user に変更

```ruby
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
```

#### :recycle: b の変数を shop に変更

```ruby
require 'net/http'
require 'json'


res = []
ARGV.each do |arg|  
  user = Net::HTTP.get(URI.parse('https://gasyuku-api.herokuapp.com/users/' + arg))
  user = JSON.parse(user)
  user['subscribed_shop_ids'].each do |id|
    shop = Net::HTTP.get(URI.parse('https://gasyuku-api.herokuapp.com/shops/' + id.to_s))
    if user['shops'] == nil
      user['shops'] = []
    end
    user['shops'].push(JSON.parse(shop))
  end
  res << user
end
puts JSON.dump(res)
```

#### :recycle: API のURLを定数化

```ruby
require 'net/http'
require 'json'

API_URL = 'https://gasyuku-api.herokuapp.com/'.freeze

res = []
ARGV.each do |arg|  
  user = Net::HTTP.get(URI.parse("#{API_URL}/users/#{arg}"))
  user = JSON.parse(user)
  user['subscribed_shop_ids'].each do |id|
    shop = Net::HTTP.get(URI.parse("#{API_URL}/shops/#{id}"))
    if user['shops'] == nil
      user['shops'] = []
    end
    user['shops'].push(JSON.parse(shop))
  end
  res << user
end
puts JSON.dump(res)
```

#### :recycle: 分かりづらい if 文をリファクタ

```ruby
require 'net/http'
require 'json'

API_URL = 'https://gasyuku-api.herokuapp.com/'.freeze

res = []
ARGV.each do |arg|  
  user = Net::HTTP.get(URI.parse("#{API_URL}/users/#{arg}"))
  user = JSON.parse(user)
  user['subscribed_shop_ids'].each do |id|
    shop = Net::HTTP.get(URI.parse("#{API_URL}/shops/#{id}"))
    user['shops'] ||= []
    user['shops'].push(JSON.parse(shop))
  end
  res << user
end
puts JSON.dump(res)

```

#### :recycle: JSONデータを一時変数に入れるのやめる

```ruby
require 'net/http'
require 'json'

API_URL = 'https://gasyuku-api.herokuapp.com/'.freeze

res = []
ARGV.each do |arg|  
  user = JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/users/#{arg}")))
  user['subscribed_shop_ids'].each do |id|
    shop = JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/shops/#{id}")))
    user['shops'] = []
    user['shops'].push(shop)
  end
  res << user
end
puts JSON.dump(res)
```

#### :recycle: user['shops'] のスコープを変更する

```ruby
require 'net/http'
require 'json'

API_URL = 'https://gasyuku-api.herokuapp.com/'.freeze

res = []
ARGV.each do |arg|  
  user = JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/users/#{arg}")))
  user['shops'] = []
  user['subscribed_shop_ids'].each do |id|
    shop = JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/shops/#{id}")))
    user['shops'].push(shop)
  end
  res << user
end
puts JSON.dump(res)
```

#### :recycle: each の構文を each_with_object に変更する

```ruby
require 'net/http'
require 'json'

API_URL = 'https://gasyuku-api.herokuapp.com/'.freeze

res = []
ARGV.each do |arg|  
  user = JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/users/#{arg}")))
  user['shops'] = user['subscribed_shop_ids'].each_with_object([]) do |id, result|
    shop = JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/shops/#{id}")))
    result.push(shop)
  end
  res << user
end

puts JSON.dump(res)
```

#### :recycle: each, each_with_object の部分を map に変換する

```ruby
equire 'net/http'
require 'json'

API_URL = 'https://gasyuku-api.herokuapp.com/'.freeze

res = ARGV.map do |arg|
  user = JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/users/#{arg}")))
  user['shops'] = user['subscribed_shop_ids'].map do |id|
    JSON.parse(Net::HTTP.get(URI.parse("#{API_URL}/shops/#{id}")))
  end
  user
end

puts JSON.dump(res)
```

#### :recycle: 配列の中の文字列をシンボルに変換する

```ruby
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
```
