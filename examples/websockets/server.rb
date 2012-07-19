require 'bundler/setup'
Bundler.setup
require 'faye'

bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
bayeux.listen(9292)
