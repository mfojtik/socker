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
      @application.class.instance_eval {
        define_method(:log) { |message| Socker::App.log(message) }
      }
      @application.freeze
      @application
    end

    def connection(env, opts={}, &block)
      conn = Faye::WebSocket.new(env)
      yield conn if block_given?
      conn.rack_response
    end

    def socket(socket=nil)
      @socket = socket
    end

    def on(event, handler)
      @events ||= {}
      @events[event] ||= lambda { |socket, ev| handler.call(socket, ev) }
    end

    def to_app
      @application
    end

    def self.log(message, level=:info)
      @log ||= Logger.new($stdout)
      @log.send(level, message)
    end

    def log(message); self.class.log(message); end

    private

    def is_websocket?(env)
      Faye::WebSocket.websocket?(env)
    end

    def register_handler(connection, env)
      lambda { |event| connection.on(event, &handle_with(event, socket: connection, env: env)) }
    end

    def handle_with(event, opts={})
      if events[event]
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
      else
        method(:handle_undefined)
      end
    end

    def handle_undefined(event)
      self.class.log("WARNING: The '#{event.type}' event is not defined.", :error)
    end

  end

end
