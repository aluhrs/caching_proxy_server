require_relative '../caching_proxy_server.rb'

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
end
