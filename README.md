# Transparent Caching Proxy Server

To test:

1) Git clone the project
2) gem install timecop
3) rspec spec/caching_proxy_server_spec.rb

To manually test:

1) Run the program
2) Open a browser
3) Type in localhost:2000/maps (or anything). It should respond with a response as well as 'Received response from server:'
4) After the / type in anything else. It should respond with a response as well as 'Received response from server:'
5) Type in /maps (or the first thing you typed again). It should respond with a response as well as 'You've hit the cache.'
