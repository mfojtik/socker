require 'puma'

load './chat.rb'

Faye::WebSocket.load_adapter('puma')

use Rack::Static, :urls => ["/images", "/js", "/css", "/index.html"], :root => "public"

run Rack::URLMap.new('/' => ChatServer.new.to_app)
