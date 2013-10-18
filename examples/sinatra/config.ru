require 'puma'

load './timeserver.rb'

Faye::WebSocket.load_adapter('puma')

run TimeServer
