# Transparent Caching Proxy Server

##Setting Up the Project

1. Clone the project
2. ```bundle install```

##Automated Unit Testing
1. ```rspec spec/caching_proxy_server_spec.rb```

##Manual Integration Testing:

1. Run the program - ```ruby init.rb``` It will prompt you, but the information is also below.
2. Open a browser.
3. Type in localhost:2000/one (or anything after the slash). It should respond with a response as well as 'Received response from server:'
4. After the / type in anything else. It should respond with a response as well as 'Received response from server:'
5. Type in /maps (or the first thing you typed again). It should respond with a response as well as 'You've hit the cache.'

Notes:

The cache is set up as so:

```ruby
  cache = {
            hashed_pathname: {
                                date_stored: Time.now, # as an int
                                size: 1024,
                                response: "this is the response from the destination source"
                              }
        }
```

Extra TODOs:
1) Use Net::HTTP for automated integration testing.
