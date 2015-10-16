load 'caching_proxy_server.rb'

while true
  puts "Please enter 'run server' to start the program. To exit the program, type 'exit'> "
  command = gets.chomp.downcase
  if command == 'exit'
    abort("Closing program")
  elsif command == "run server"
    puts "Opening server connection. A browser window should open, but if not, please open a browser window and type in: localhost:2000/<something> ex: localhost:2000/images"
    `open http://localhost:2000/images`
    CachingProxyServer.new.start_server
  end
end
