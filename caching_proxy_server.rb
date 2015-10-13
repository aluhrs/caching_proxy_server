require 'socket'
require 'uri'
require 'digest'

# TODO: figure out testing - use rspec and timecop!
# TODO: closing program is a little wonky; only closes program if it's the first line

# cache = {
#   url = { date_stored:
#   size:
#   response:
#   }
# }

class CachingProxy
  attr_accessor :cache, :cache_size, :cache_configuration, :ordered_urls, :cache_configuration

  def initialize(cache_configuration={})
    @cache = {}
    @cache_size = 0
    @ordered_urls = []
    @cache_configuration = !cache_configuration.empty? ? cache_configuration : default_configuration
  end

  # Open a server connection and accept requests.
  def server
    server = TCPServer.new 2000
    response = ''
    loop do
      break if gets.chomp == "exit"
      client = server.accept
      url = client.gets
      pathname = parse_url(url)
      hashed_pathname = hash_pathname(pathname)
      response = nil
      cached_response = get_cached_version(hashed_pathname)
      if cached_response
        response = "You've hit the cache. The response is: #{cached_response}"
      else
        response = "Received response from server: #{fetch_from_source(pathname)}"
        make_space(response)
        add_to_cache(hashed_pathname, response)
        add_to_ordered_urls(url)
      end

      client.puts response
      client.close
    end
  end

  def get_cached_version(pathname)
    if cache[pathname]
      current_time = Time.now.to_i
      if (current_time - cache[pathname][:date_stored]) < default_configuration[:cacheDuration]
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

  # get pathname
  def parse_url(url)
    url = url.split(' ')
    url[1]
  end

  def hash_pathname(pathname)
    Digest::MD5.hexdigest(pathname)
  end

  def make_space(response)
    if too_many_elements_in_cache?
      ordered_urls.shift
    elsif not_enough_space?(response)
      while not_enough_space do
        ordered_urls.shift
      end
    end
  end

  def too_many_elements_in_cache?
    cache.size < default_configuration[:cacheSizeElements]
  end

  def not_enough_space?(response)
    (response.size + cache_size) < default_configuration[:cacheSizeBytes]
  end

  def add_to_cache(url, response)
    cache[url] = {
      date_stored: Time.now.to_i,
      size: response.bytesize,
      response: response
    }
  end

  def add_to_ordered_urls(url)
    ordered_urls << url
  end

  private

  def default_configuration
    {
      cacheDuration: 30 * 1000, # seconds
      cacheSizeBytes: 1024 * 2, # total size of cache in bytes
      cacheSizeElements: 50 # total of elements in cache
    }
  end
end

CachingProxy.new.server
