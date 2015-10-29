require_relative '../caching_proxy_server.rb'

describe CachingProxyServer do
  let(:server) { CachingProxyServer.new }

  describe "#parse_url" do
    it "returns the pathname of the url" do
      expect(server.parse_url("GET /maps HTTP/1.1")).to eq("/maps")
    end
  end
end
