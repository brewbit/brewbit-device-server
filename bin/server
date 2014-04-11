#!/usr/bin/env ruby

require_relative '../config'

require 'eventmachine'
require 'thin'
require 'device_connection'
require 'web_server'

EventMachine::run {
  Signal.trap("INT")  { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  EventMachine::start_server HOST, DEVICE_PORT, DeviceConnection
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

