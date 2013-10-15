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
