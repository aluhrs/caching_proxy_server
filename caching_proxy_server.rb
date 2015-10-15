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
    @cache_configuration = {
                              cache_duration: 30 * 1000, # seconds
                              cache_size_bytes: 1024 * 2, # total size of cache in bytes
                              cache_size_elements: 2 # total of elements in cache
                            }
  end

  # Open a server connection and accept requests.
  def start_server
    server = TCPServer.new 2000
    response = nil
    loop do
      client = server.accept
      url = client.gets
      pathname = parse_url(url)
      # favicon is returned on every request. it's noisy, so let's ignore it.
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

      client.puts response
      client.close
    end
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
    @cache_size = update_cache_size(response)
    add_to_ordered_urls(hashed_pathname)
  end

  # get pathname
  def parse_url(url)
    url = url.split(' ')
    url[1]
  end

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
    @cache_size = delete_from_cache_size(url_to_delete_size)
    cache.delete(url_to_delete)
  end

  def delete_from_cache_size(url_to_delete_size)
    @cache_size - url_to_delete_size
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
    @cache_size + response.bytesize
  end

  def add_to_ordered_urls(url)
    ordered_urls << url
  end
end
