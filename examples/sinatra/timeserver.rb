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
