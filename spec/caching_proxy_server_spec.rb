require_relative '../caching_proxy_server.rb'
require 'timecop'

describe CachingProxyServer do
  let(:server) { CachingProxyServer.new }
  let(:cached_pathname) { Digest::MD5.hexdigest('/maps') }

  before(:each) do
    server.cache[cached_pathname] = {
                                      date_stored: Time.now.to_i,
                                      size: 1024,
                                      response: "This the response",
                                    }
  end

  describe "#parse_url" do
    it "returns the pathname of the url" do
      expect(server.parse_url("GET /maps HTTP/1.1")).to eq("/maps")
    end
  end

  describe "#make_space" do
    let(:response) { "this is the response" }
    before(:each) do
      server.ordered_urls = [ cached_pathname ]
      server.cache_size = 1024
    end

    context "too many elements" do
      it "removes an element from the cache" do
        server.cache_configuration[:cache_size_elements] = 1
        expect(server.cache.size == 1)
        server.make_space(response)
        expect(server.cache.size == 0)
      end
    end

    context "not enough space" do
      it "removes elements from the cache" do
        server.cache_configuration[:cache_size_bytes] = 30
        expect(server.cache.size == 1)
        server.make_space(response)
        expect(server.cache.size == 0)
      end
    end
  end

  describe "#room_for_more_elements?" do
    it "returns false if the cache has too many elements" do
      server.cache_configuration[:cache_size_elements] = 1
      expect(server.room_for_more_elements?).to be false
    end

    it "returns true if the cache has room for more elements" do
      expect(server.room_for_more_elements?).to be true
    end
  end

  describe "#enough_space?" do
    before(:each) do
      cache_size = 1024
    end
    let(:response) { "this is the response" }

    it "returns false if the cache does not have space" do
      server.cache_configuration[:cache_size_bytes] = 1
      expect(server.enough_space?(response)).to be false
    end

    it "returns true if the cache has space" do
      expect(server.enough_space?(response)).to be true
    end
  end

  describe "#get_cached_version" do
    it "returns the response from the cache" do
      # travel forward in time 60 seconds
      Timecop.travel(Time.now + 60) do
        expect(server.get_cached_version(cached_pathname)).to eq(server.cache["#{cached_pathname}"][:response])
      end
    end
  end
end
