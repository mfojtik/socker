Gem::Specification.new do |s|
  s.name        = 'socker'
  s.version     = '0.0.4'
  s.summary     = 'Framework for building WebSocket applications'
  s.description = "A simple lib that helps you build awesome websockets apps"
  s.authors     = ["Michal Fojtik"]
  s.email       = 'mi@mifo.sk'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/mfojtik/socker'
  s.add_runtime_dependency 'faye-websocket'
end
