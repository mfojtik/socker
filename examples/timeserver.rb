require 'socker'

class TimeServer < Socker::App

  def initialize
    on(:open, method(:handle_new_connection))
    on(:close, method(:handle_closed_connection))
    super(
      when_active: method(:start_timeserver),
      when_idle: method(:stop_timeserver)
    )
  end

  def handle_new_connection(socket, event)
    log "#new_connection established"
  end

  def handle_closed_connection(socket, event)
    log "#connection_closed :("
  end

  def start_timeserver
    @timeserver = EM.add_periodic_timer(1) { broadcast(Time.now.to_s) }
  end

  def stop_timeserver
    @timeserver.cancel
  end

end
