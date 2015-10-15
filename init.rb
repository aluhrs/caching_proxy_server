load 'caching_proxy_server'

while true
  puts "Please enter 'run server' to start the program. To exit the program, type 'exit'> "
  command = gets.chomp.downcase
  if command == 'exit'
    abort("Closing program")
  elsif command == "run server"
    puts "Opening server connection. A browser should open for you, but if not, please open a browser window and type in: localhost:2000/<something> ex: localhost:2000/maps"
    'open localhost:2000/maps'
    CachingProxyServer.new.start_server
  end
end
