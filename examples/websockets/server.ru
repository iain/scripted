require 'bundler/setup'
Bundler.setup

require File.expand_path("../server.rb", __FILE__)

require 'faye'
Faye::WebSocket.load_adapter 'thin'
use Faye::RackAdapter, :mount => '/faye'

run Sinatra::Application
