# Transparent Caching Proxy Server

##Setting Up the Project

1. Clone the project
2. ```bundle install```

##Automated Unit Testing
1. ```rspec spec/caching_proxy_server_spec.rb```

##Manual Integration Testing:

*Note: These are not intended to be working URLs. They're just for testing purposes.*

1. Run the program: ```ruby init.rb```
2. A browser directed to localhost:2000/one should open for you. It may take a second to load. It should respond with 'Received response from server:' as well as the response from http://google.com/one.
3. Testing for elements in cache:
   - Type in localhost:2000/two (or anything after the slash). It should respond with 'Received response from server:' as well as the response from http://google.com/two (or whatever you typed in).
   - Since the maximum elements in the cache is set to 2, if you type in localhost:2000/one again, it should respond with 'You've hit the cache' as well as the cached response.
   - Typing in 2 other separate requests and then localhost:2000/one again should result in 'Received response from server:'.
4. Testing for duration:
   - Make one request and then waiting ~2 minutes to make the next request. It should result in 'Received response from server:'.
5. Testing for bytesize:
   - There are print statements in the console alerting you to how much space is left. Once the limit is reached, the oldest item in the cache is removed. There will also be a print statement in the console alerting you that an item has been removed.
   - Another way to test this is to lower the cache bytesize to a small number. When running the program, with the first page opening, it should immediately hit the limit. Making the same request should respond with 'Received response from server:' as the prior response failed to save to the cached.
6. Exit program by using ctrl c.

##Notes:

The cache is set up as:

```ruby
  cache = {
            hashed_pathname: {
              date_stored: Time.now.to_i, # force into an int
              size: 1024,
              response: "This is the response from the destination source."
            }
          }
```

##Possible Enhancements:
- Test hitting the server by using Net::HTTP for automated integration testing.
