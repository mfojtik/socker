require 'socker'
require 'json/pure'

class ChatServer < Socker::App

  def initialize
    on :open, method(:joined)
    on :close, method(:left)
    on :message, method(:message_received)
    super
  end

  def joined(socket, event)
    broadcast JSON::dump(message: "#{params['ip']} just joined the chat", from: 'chat')
  end

  def left(socket, event)
    broadcast JSON::dump(message: "#{params['ip']} left the chat", from: 'chat')
  end

  def message_received(socket, event)
    broadcast JSON::dump(message: event.data, from: params['ip'])
  end

end
