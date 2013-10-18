require_relative '../lib/socker'
require "minitest/autorun"

describe Socker do

  before do
    @app = Socker::App.new
  end

  it '#log' do
    out, _ = capture_io do
      @app.log("test")
    end
    out.must_match(/test/)
    out.must_match(/INFO/)
  end

  it 'raise error when registering unsupported event' do
    lambda { @app.on(:unknown) }.must_raise RuntimeError
  end

  it 'supports handler by referencing a method' do
    class Test
      def self.handler; true end
    end
    @app.on(:open, Test.method(:handler))
    @app.events[:open].class.must_equal Proc
  end

  it 'supports handler by using block' do
    @app.on(:open) { true }
    @app.events[:open].class.must_equal Proc
  end

  it 'supports :active handler when setting a callback' do
    @app.on(:active) { true }
    @app.callbacks[:when_active].class.must_equal Proc
  end

  it 'supports :idle handler when setting a callback' do
    @app.on(:idle) { true }
    @app.callbacks[:when_idle].class.must_equal Proc
  end

  it '#to_app' do
    @app.to_app.class.must_equal Proc
  end

end
