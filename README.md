socker
======

A simple Ruby framework to build awesome WebSocket applications.
The framework is based on the [faye/websocket](https://github.com/faye/faye-websocket-ruby) library.

## Example

```ruby
require 'socker'

class TimeServer < Socker::App

  def initialize
    on :open, method(:connected)
    on :close, method(:disconnect)
    super(
      when_active: method(:start_timeserver),
      when_idle: method(:stop_timeserver)
    )
  end

  def connected(socket, event)
    log "Yay! Somebody just connected, lets start sending him current time."
  end

  def disconnect(socket, event)
    log "Somebody has left :-("
  end

  def start_timeserver
    @timeserver = EM.add_periodic_timer(1) { broadcast(Time.now.to_s) }
  end

  def stop_timeserver
    @timeserver.cancel
  end

end
```

You can use [puma](http://puma.io/) to deploy this application. You also need
HTML file with the JavaScript code (check examples/ directory), that will
connect to this server and establish connection.

The Socker::App will then start a new EM timer and broadcast the current
time to all connected users. After the last user disconnect, the EM timer will
be killed (and restarted again when someone connect again).

## Installation

It is Ruby, so:

```
$ gem install socker
```

or add Socker to your Gemfile:

```
source 'https://rubygems.org'

gem 'socker'
```

## How to run it?

As Socker is Rack compatible, you can use `config.ru` to spawn the WebSocket
server. Your app can be also mounted to any Sinatra/Rails/Rack-compatible app
and provide the WebSocket layer together with the regular HTTP server.

A simple example of `config.ru`:

```ruby
require 'puma'
load './timeserver.rb'

Faye::WebSocket.load_adapter('puma')

# This will make public/* files available in browser:
use Rack::Static, :urls => ["/images", "/js", "/css", "/index.html"], :root => "public"

# Mount the TimeServer application to '/' URI.
run Rack::URLMap.new('/' => TimeServer.new.to_app)
```

## License

Copyright 2013 Michal Fojtik

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
