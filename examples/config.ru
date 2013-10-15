require 'puma'

load './timeserver.rb'

Faye::WebSocket.load_adapter('puma')

use Rack::Static, :urls => ["/images", "/js", "/css", "/index.html"], :root => "public"

run Rack::URLMap.new('/' => TimeServer.new.to_app)
