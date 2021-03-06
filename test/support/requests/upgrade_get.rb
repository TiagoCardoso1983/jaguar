module Requests
  module UpgradeGet

    def test_upgrade_get
      server.run do |req, rep|
        rep.body = %w(Right)
      end

      response = client.request(:get, "#{server_uri}/", 
                                headers: {"Upgrade" => "h2c", 
                                          "HTTP2-Settings" =>  "AAMAAABkAAQAAP__"})

      assert response.status == 101, "couldn't switch protocols"

      up = upgrade_client(client.conn.instance_variable_get(:@socket).io)

      response = up.response

      assert response.status == 200, "couldn't parse upgraded http2 status"
    end

    private

    def upgrade_client(sock)
      @upgrade_client ||= begin
        up = Jaguar::HTTP2::Client.new(sock)
        up.upgrade
        up
      end
    end
 
  end
end
