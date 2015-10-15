load 'caching_proxy_server.rb'

while true
  puts "Please enter 'run server' to start the program. To exit the program, type 'exit'> "
  command = gets.chomp.downcase
  if command == 'exit'
    abort("Closing program")
  elsif command == "run server"
    puts "Opening server connection. Please open a browser window and type in: localhost:2000/<something> ex: localhost:2000/maps"
    CachingProxyServer.new.start_server
  end
end
