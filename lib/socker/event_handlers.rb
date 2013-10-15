module Socker

  module EventHandlers

    def connections
      @connections ||= []
    end

    def on_open(connection)
      @callbacks[:when_active].call if connections.empty? and @callbacks[:when_active]
      connections << connection
    end

    def on_close(connection)
      connections.delete(connection)
      @callbacks[:when_idle].call if connections.empty? and @callbacks[:when_active]
    end

    def handle(event, connection)
      case event
      when :open then on_open(connection)
      when :close then on_close(connection)
      end
    end

  end

end
