module Socker

  module Helper

    # This function send an broadcast message to all active connections.
    # The message must be String (but you can sent a JSON, etc..)
    #
    def broadcast(message)
      connections.each do |c|
        begin
          c.send(message)
        rescue => error
          log("ERROR: Connection #{c} seems invalid, ignoring. (#{error.message})")
        end
      end
    end

    # If the protocol support PING, you can send this to all clients and when
    # they replied with PONG message, you can handle that with callback.
    #
    def pbroadcast(message, callback)
      connections.each { |c| c.ping(message, &callback) }
    end

    # Provide access to the Rack params used for WebSocket connection, ie:
    #
    # socket = new Socket('ws://' + location.hostname + ':' + '9292' + '/?param1=value')
    #
    def params
      @env.params
    end

  end

end
