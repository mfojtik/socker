socker
======

A simple Ruby framework to build awesome WebSocket applications. The Socker
library could be used as a standalone Rack application or inside [Sinatra](http://www.sinatrarb.com/) using
the Socker Sinatra extension.

The framework is based on the [faye/websocket](https://github.com/faye/faye-websocket-ruby) library.

## Changelog:

* 0.0.4: Added support for Sinatra and Sinatra example
* 0.0.1-0.0.3: Initial implementation and PoC, nothing interesting :-)

## Demo

You can see the **chat** application demo (available in examples/ folder) in
action here:

http://socker-mfojtik.rhcloud.com/index.html

## Documentation

RDOC: [rdoc.info/github/mfojtik/socker](http://rdoc.info/github/mfojtik/socker)

## Example

### Standalone websocket application

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

You can use any websockets enabled server (like [puma](http://puma.io/)) to deploy this application.

You also need HTML file with the JavaScript code (check examples/ directory),
that will speak to this server.

The `Socker::App` will then spawn a new EM timer and broadcast the current
time to all connected users. After the last user disconnect, the EM timer will
be killed (and restarted again when someone connect again).

Check the complete
[examples/timeserver](https://github.com/mfojtik/socker/tree/master/examples/timeserver)
folder for more details.

### Sinatra modular application

Yes! You can use Socker as a Sinatra extension as well. In that case you don't
need to anything from the example above, Sinatra will handle everything for you.
All you need to do is to define a `websocket` route and then use that route in
your HTML view.

```ruby
require 'sinatra/base'
require 'socker/sinatra'

class TimeServer < Sinatra::Base
  register Sinatra::Socker

  websocket '/socket' do

    on(:active) {
      log "Starting the time broadcast!"
      @timeserver = EM.add_periodic_timer(1) { broadcast(Time.now.to_s) }
    }

    on(:idle) {
      log "Noone connected, stopping time  broadcasting."
      @timeserver.cancel
    }

    on(:open) { |socket, _|
      log "Somebody just connected!"
    }

    on(:close) { |socket, _|
      log "Somebody just left :-("
    }

  end

  get '/' do
    erb :index
  end

end
```

Check the [examples/sinatra](https://github.com/mfojtik/socker/tree/master/examples/sinatra) folder for
complete example.


## Installation

It is Ruby, so:

```
$ gem install socker
```

or add Socker to your Gemfile:

```
source 'https://rubygems.org'

gem 'socker'

# or if you want use Sinatra extension:
# gem 'socker', :requre => 'socker/sinatra'
```

## How to run standalone app?

Standalone Socker app is really a Rack app, so you can use `config.ru` to spawn it.

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
