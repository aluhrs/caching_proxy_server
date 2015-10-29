require 'socket'
require 'uri'
require 'digest'
load 'cache.rb'

class CachingProxyServer
  attr_accessor :new_cache

  # Open a server connection and accept requests
  def start_server
    server = TCPServer.new 2000
    response = nil
    source_time = nil
    loop do
      client = server.accept
      url = client.gets
      if url && proceed?(source_time)
        pathname = parse_url(url)
        # Favicon is returned on every request. It's noisy, so let's ignore it.
        unless pathname == '/favicon.ico'
          hashed_pathname = hash_pathname(pathname)
          cached_response = get_cached_version(hashed_pathname)
          if cached_response
            response = "You've hit the cache. The response from #{pathname} is: #{cached_response}"
          else
            response = "Received response from #{pathname}: #{fetch_from_source(pathname)}"
            @new_cache.store_data(pathname, response, hashed_pathname)
          end
        end
      end

      client.puts response
      client.close
      puts "closing client"
      source_time = Time.now.to_i
    end
  end

  # An issue was happening where after correctly grabbing the response from the
  # destination source and adding it to the cache, the server accepted another
  # request almost immediately. This was causing the 'Received from cache to
  # be printed to the browser' and you would never see the initial 'Received
  # from destination source' message in the browser. For testing puproses, to
  # ensure you still see the 'Received from destination source' message in the
  # browser, adding logic to display the response saved rather than then
  # grabbing from the cache if it's been less than a second since grabbing from
  # the destination source.
  def proceed?(source_time)
    current_time = Time.now.to_i
    source_time ? ((current_time - source_time) >= 1) : true
  end

  def new_cache
    @new_cache ||= Cache.new
  end

  def get_cached_version(pathname)
    new_cache.get_cached_version(pathname)
  end

  def fetch_from_source(pathname)
    # For testing purposes, test against google
    url = "http://www.google.com#{pathname}"
    parsed_url = URI.parse(url)
    connection = TCPSocket.new parsed_url.host, 80
    response = ''
    connection.puts "GET / HTTP/1.1"
    connection.puts "Host: #{parsed_url.host}"
    connection.puts "Connection: close"

    connection.puts "\n"
    while line = connection.gets
      response += line
    end

    puts "Done downloading #{url.to_s}"
    connection.close
    response
  end

  # Get pathname
  def parse_url(url)
    url = url.split(' ')
    url[1]
  end

  # Hash the pathname for security purposes
  def hash_pathname(pathname)
    Digest::MD5.hexdigest(pathname)
  end
end
