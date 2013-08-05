#!/usr/bin/env ruby

require './config'

require 'eventmachine'
require 'thin'
require 'model_t_server'
require 'web_server'

EventMachine::run {
  Signal.trap("INT")  { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  EventMachine::start_server HOST, DEVICE_PORT, ModelTServer
  puts "running device server on #{HOST}@#{DEVICE_PORT}"

  dispatch = Rack::Builder.app do
    map '/' do
      run WebServer.new
    end
  end

  Rack::Server.start({
    app:    dispatch,
    server: 'thin',
    Host:   HOST,
    Port:   WEB_PORT
  })
}

