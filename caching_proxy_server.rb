require 'socket'
require 'uri'
require 'digest'

class CachingProxyServer
  attr_accessor :cache, :cache_size, :cache_configuration, :ordered_urls, :cache_configuration

  def initialize
    @cache = {}
    # exposes current cache size for easy access to total size of response bytes
    @cache_size = 0
    # used for easy lookup to the cache hash
    @ordered_urls = []
    # keeping elements low for testing purposes
    @cache_configuration = {
                              cache_duration: 30 * 1000, # seconds
                              cache_size_bytes: 1024 * 10000, # total size of cache in bytes
                              cache_size_elements: 2 # total # of elements in cache
                            }
  end

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
            store_data(pathname, response, hashed_pathname)
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
    source_time ? ((current_time - source_time) > 1) : true
  end

  def get_cached_version(pathname)
    if cache[pathname]
      current_time = Time.now.to_i
      if (current_time - cache[pathname][:date_stored]) < cache_configuration[:cache_duration]
        cache[pathname][:response]
      end
    end
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

  def store_data(pathname, response, hashed_pathname)
    make_space(response)
    add_to_cache(hashed_pathname, response)
    update_cache_size(response)
    add_to_ordered_pathnames(hashed_pathname)
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

  def make_space(response)
    if !room_for_more_elements?
      delete_from_cache
    elsif !enough_space?(response)
      while !enough_space?(response) do
        delete_from_cache
      end
    end
  end

  def delete_from_cache
    url_to_delete = ordered_urls.shift
    url_to_delete_size = cache[url_to_delete][:size]
    @cache_size -= url_to_delete_size
    cache.delete(url_to_delete)
  end

  def room_for_more_elements?
    cache.size < cache_configuration[:cache_size_elements]
  end

  def enough_space?(response)
    (response.bytesize + @cache_size) <= cache_configuration[:cache_size_bytes]
  end

  def add_to_cache(url, response)
    cache[url] = {
                    date_stored: Time.now.to_i,
                    size: response.bytesize,
                    response: response
                  }
  end

  def update_cache_size(response)
    @cache_size += response.bytesize
  end

  # Storing an ordered list of the pathnames so that when need to remove from
  # cache, to get the oldest item, I can simply take the first item in this list
  # then look it up in the cache and remove it.
  def add_to_ordered_pathnames(pathname)
    ordered_urls << pathname
  end
end
