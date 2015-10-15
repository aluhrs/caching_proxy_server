# Transparent Caching Proxy Server

##To test:

1. Git clone the project
2. ```gem install timecop```
3. ```rspec spec/caching_proxy_server_spec.rb```

##To manually test:

1. Run the program - ```ruby init.rb```
2. It will prompt you, but the information is also below.
3. Open a browser
4. Type in localhost:2000/maps (or anything after the slash). It should respond with a response as well as 'Received response from server:'
5. After the / type in anything else. It should respond with a response as well as 'Received response from server:'
6. Type in /maps (or the first thing you typed again). It should respond with a response as well as 'You've hit the cache.'

Notes:

The cache is set up as so:

```ruby
  cache = {
    pathname is stored by using MD5 hashing
    hashed_pathname = {
            date_stored: Time.now, # as an int
            size: 1024,
            response: "this is the response from the destination source"
          }
        }
```
