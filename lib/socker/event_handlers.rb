module Socker

  module EventHandlers

    # The list of active connections.
    # This list is used for 'broadcasting' messages to all active connections
    #
    def connections
      @connections ||= []
    end

    # When a new connection is opened, we save it into the list
    # of connections (so methods like 'broadcast' works). Also the :when_active
    # callback is executed when this is a first connection.
    #
    def on_open(connection)
      @callbacks[:when_active].call if connections.empty? and @callbacks[:when_active]
      connections << connection
    end

    # When connection is closed, we remove it from the connections list and
    # execute the :when_idle callback.
    #
    def on_close(connection)
      connections.delete(connection)
      @callbacks[:when_idle].call if connections.empty? and @callbacks[:when_idle]
    end

    def handle(event, connection)
      case event
      when :open then on_open(connection)
      when :close then on_close(connection)
      end
    end

  end

end
