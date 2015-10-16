# Transparent Caching Proxy Server

##Setting Up the Project

1. Clone the project
2. ```bundle install```

##Automated Unit Testing
1. ```rspec spec/caching_proxy_server_spec.rb```

##Manual Integration Testing:

1. Run the program: ```ruby init.rb```
2. A browser directed to localhost:2000/one should open for you. It may take a second to load. It should respond with 'Received response from server:' as well as the response from http://google.com/one.
3. Type in localhost:2000/two (or anything after the slash). It should respond with 'Received response from server:' as well as the response from http://google.com/two.
4. Since the maximum elements in the cache is set to 2, if type in localhost:2000/one again, it should respond with 'You've hit the cache' as well as the cached response.
5. Similar testing can be done for duration and bytesize, eg make one request and then waiting ~2 minutes to make the next request.
6. Exit program by using ctrl c.

Notes:

The cache is set up as so:

```ruby
  cache = {
            hashed_pathname: {
              date_stored: Time.now.to_i, # force into an int
              size: 1024,
              response: "This is the response from the destination source."
            }
          }
```

Possible Enhancements:
1. Test hitting the server by using Net::HTTP for automated integration testing.
