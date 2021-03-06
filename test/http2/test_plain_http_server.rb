require_relative "../test_container"

class HTTP2PlainHTTPServer < ContainerTest
  def setup
    Celluloid.init
    @app = Jaguar::Container.new("http://127.0.0.1:8989")
  end

  def test_get
    server = @app.send(:build_server)
    server.run(&method(:get_app))

    sock = TCPSocket.new("127.0.0.1", 8989)
    client = http_client(sock)
    get_request(client)

    client.read(1024)

    response = client.response
    assert response.headers[":status"] == "200", "response is unexpected"
    assert response.headers[":content-type"] == "5", "response is unexpected"
    assert response.body == "Right", "response is unexpected"
  ensure
    sock.close if sock 
    server.stop if server
  end



  private

  def http_client(sock)
    HTTP2Client.new(sock)
  end

  def get_app(req, rep)
    if req.url == "/"
      rep.body = %w(Right)
      rep.headers[":content-type"] = rep.body.map(&:bytesize).reduce(:+)
    else
      rep.status = 400
      rep.headers["content-type"] = rep.body.map(&:bytesize).reduce(:+)
      rep.body = %w(Wrong)
    end
  end


  def get_request(client)
    headers = { ":scheme" => "http", ":method" => "GET", ":path" => "/",
                "accept" => "*/*"}
    client.write headers
  end

  def get_response_success
    "HTTP/1.1 200 OK\r\nContent-Type: 5\r\nRight\r\n\r\n"
  end
end

