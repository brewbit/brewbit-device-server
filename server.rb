#!/usr/bin/env ruby

require './config'

require 'eventmachine'
require 'thin'
require 'device_connection'
require 'web_server'

puts "Starting device server on #{HOST}:#{DEVICE_PORT}"
puts "Starting web server on #{HOST}:#{WEB_PORT}"
puts "Using brewbit API at #{BREWBIT_API_HOST}"

EventMachine::run {
  Signal.trap("INT")  { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  EventMachine::start_server HOST, DEVICE_PORT, DeviceConnection do |connection|
    connection.comm_inactivity_timeout = DEVICE_CONNECTION_TIMEOUT
  end

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

