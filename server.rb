#!/usr/bin/env ruby

require './config'

require 'eventmachine'
require 'model_t'

EventMachine::run {
  Signal.trap("INT")  { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }

  EventMachine::start_server HOST, PORT, ModelTServer

  puts "running echo on #{HOST}@#{PORT}"
}

