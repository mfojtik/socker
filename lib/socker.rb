require_relative './socker/event_handlers.rb'
require_relative './socker/helper.rb'

require 'faye/websocket'
require 'logger'

module Socker

  class App

    include Socker::EventHandlers
    include Socker::Helper

    WEBSOCKET_STANDARD_EVENTS = [ :open, :close, :message, :error ]

    attr_reader :events, :callbacks

    def initialize(callbacks={})
      @callbacks = callbacks
      @application = lambda do |env|
        return [501, {}, ['Sorry, but I am websocket app.']] unless is_websocket?(env)
        connection(env) do |c|
          WEBSOCKET_STANDARD_EVENTS.each(&register_handler(c, env))
        end
      end
      # This is needed for Puma so we can log the requests to WebSockets
      @application.class.instance_eval {
        define_method(:log) { |message| Socker::App.log(message) }
      }
      @application.freeze
      @application
    end

    # Helper method your application can use to register new handlers
    # Supported events handlers are:
    #
    # * open    - The connection was succesfully established
    # * close   - The connection was closed
    # * error   - An error occured on the client side
    # * message - A message was received from the socket
    #
    # Handler could be anything that implements the .call method, like
    # lambda, Proc or Method...
    #
    def on(event, handler)
      @events ||= {}
      raise "Unable register handler for unsupported event: #{event}" unless event_supported?(event)
      @events[event] ||= lambda { |socket, ev| handler.call(socket, ev) }
    end

    # A method used for mounting the application to Rack:
    #
    # run Rack::URLMap.new('/' => MyServer.new.to_app)
    #
    def to_app
      @application
    end

    # The default logging destination for the application.
    # If you want to use custom logging or logging to a file, you can override
    # this method.
    #
    def self.log(message, level=:info)
      @log ||= Logger.new($stdout)
      @log.send(level, message)
    end

    def log(message)
      self.class.log(message)
    end

    private

    def connection(env, opts={}, &block)
      conn = Faye::WebSocket.new(env)
      yield conn if block_given?
      conn.rack_response
    end

    def event_supported?(event)
      true if WEBSOCKET_STANDARD_EVENTS.include?(event.to_sym)
    end

    def is_websocket?(env)
      Faye::WebSocket.websocket?(env)
    end

    def register_handler(connection, env)
      lambda { |event| connection.on(event, &handle_with(event, socket: connection, env: env)) }
    end

    def handle_with(event, opts={})
      return method(:handle_missing) if !events[event]
      current_class = self.class
      lambda do |ev|
        @env = Rack::Request.new(opts[:env])
        begin
          handle(event, opts[:socket])
          events[event].call(opts[:socket], ev)
        rescue => error
          current_class.log("[#{error.class}] #{error.message}\n#{error.backtrace.join("\n")}", :error)
        end
      end
    end

    # When the browser sent an event which has no handler defined, show an error
    # message in the log, but don't crash the application.
    #
    def handle_missing(event)
      self.class.log("WARNING: I dont know how to handle the '#{event.type}' event.", :error)
    end

  end

end
