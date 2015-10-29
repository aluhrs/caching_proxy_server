class Cache
  attr_accessor :cache_configuration, :cache, :cache_size, :ordered_urls

  def initialize
    @cache = {}
    @cache_size = 0
    @ordered_urls = []
    @cache_configuration = {
                            cache_duration: 120, # seconds
                            cache_size_bytes: 1024 * 1000, # total size of cache in bytes
                            cache_size_elements: 2 # total # of elements in cache
                          }
  end

  def get_cached_version(pathname)
    if cache[pathname]
      current_time = Time.now.to_i
      if (current_time - cache[pathname][:date_stored]) < cache_configuration[:cache_duration]
        cache[pathname][:response]
      end
    end
  end

  def add_to_cache(url, response)
    cache[url] = {
                    date_stored: Time.now.to_i,
                    size: response.bytesize,
                    response: response
                  }
  end

  def store_data(pathname, response, hashed_pathname)
    if make_space(response) != false
      add_to_cache(hashed_pathname, response)
      update_cache_size(response)
      add_to_ordered_pathnames(hashed_pathname)
    end
  end

  def update_cache_size(response)
    @cache_size += response.bytesize
  end

  def delete_from_cache
    url_to_delete = ordered_urls.shift
    url_to_delete_size = cache[url_to_delete][:size]
    @cache_size -= url_to_delete_size
    cache.delete(url_to_delete)
    puts "Item was removed from cache"
  end

  def make_space(response)
    return false if too_big_for_total_cache?(response)

    if !room_for_more_elements?
      delete_from_cache
    elsif !enough_space?(response)
      while !enough_space?(response) do
        delete_from_cache
      end
    end
  end

  # If the response is too big for the total cache size, let's not cache it.
  def too_big_for_total_cache?(response)
    # Adding print statments for testing purposes.
    puts "Response Bytesize: #{response.bytesize}"
    puts "Cache Bytesize: #{@cache_size}"
    puts "Room left in cache BEFORE adding current response: #{cache_configuration[:cache_size_bytes] - @cache_size}"
    response.bytesize > cache_configuration[:cache_size_bytes]
  end

  def room_for_more_elements?
    cache.size < cache_configuration[:cache_size_elements]
  end

  def enough_space?(response)
    (response.bytesize + @cache_size) <= cache_configuration[:cache_size_bytes]
  end

  # Storing an ordered list of the pathnames so that when need to remove from
  # cache, to get the oldest item, I can simply take the first item in this list
  # then look it up in the cache and remove it.
  def add_to_ordered_pathnames(pathname)
    ordered_urls << pathname
  end
end
