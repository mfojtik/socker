require 'socker'
require 'sinatra/base'

module Sinatra

  module Socker

    class RackAdapter

      def initialize(app, options = {})
        @socker_app  = options[:app]
        @mount_point = options[:at]
        @app         = app
      end

      def call(env)
        if Rack::Request.new(env).path == @mount_point
          @socker_app.call(env)
        else
          @app.call(env)
        end
      end

    end

    def websocket(mount_point, &block)
      socker_app = ::Socker::App.new
      socker_app.instance_eval(&block)
      use Sinatra::Socker::RackAdapter, :app => socker_app.to_app, :at => mount_point
    end

  end

  register Sinatra::Socker
end
