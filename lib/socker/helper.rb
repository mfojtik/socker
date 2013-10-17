module Socker

  module Helper

    def broadcast(message)
      connections.each { |c| c.send(message) }
    end

    def pbroadcast(message, callback)
      connections.each { |c| c.ping(message, &callback) }
    end

    def params
      @env.params
    end

  end

end
