require_relative '../cache.rb'
require 'digest'
require 'timecop'

describe Cache do
  let(:new_cache) { Cache.new }
  let(:cached_pathname) { Digest::MD5.hexdigest('/maps') }
  before(:each) do
    new_cache.cache[cached_pathname] = {
                                      date_stored: Time.now.to_i,
                                      size: 1024,
                                      response: "This the response",
                                    }
  end

  describe "#make_space" do
    let(:response) { "this is the response" }
    before(:each) do
      new_cache.ordered_urls = [ cached_pathname ]
      new_cache.cache_size = 1024
    end

    context "too many elements" do
      it "removes an element from the cache" do
        new_cache.cache_configuration[:cache_size_elements] = 1
        expect(new_cache.cache.size == 1)
        new_cache.make_space(response)
        expect(new_cache.cache.size == 0)
      end
    end

    context "not enough space" do
      it "removes elements from the cache" do
        new_cache.cache_configuration[:cache_size_bytes] = 30
        expect(new_cache.cache.size == 1)
        new_cache.make_space(response)
        expect(new_cache.cache.size == 0)
      end
    end
  end

  describe "#room_for_more_elements?" do
    it "returns false if the cache has too many elements" do
      new_cache.cache_configuration[:cache_size_elements] = 1
      expect(new_cache.room_for_more_elements?).to be false
    end

    it "returns true if the cache has room for more elements" do
      expect(new_cache.room_for_more_elements?).to be true
    end
  end

  describe "#enough_space?" do
    before(:each) do
      cache_size = 1024
    end
    let(:response) { "this is the response" }

    it "returns false if the cache does not have space" do
      new_cache.cache_configuration[:cache_size_bytes] = 1
      expect(new_cache.enough_space?(response)).to be false
    end

    it "returns true if the cache has space" do
      expect(new_cache.enough_space?(response)).to be true
    end
  end

  describe "#get_cached_version" do
    it "returns the response from the cache" do
      # travel forward in time 60 seconds
      Timecop.travel(Time.now + 60) do
        expect(new_cache.get_cached_version(cached_pathname)).to eq(new_cache.cache["#{cached_pathname}"][:response])
      end
    end
  end
end
