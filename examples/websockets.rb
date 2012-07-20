# This is an example of using the websockets formatter.  Admittedly, this
# example is a bit meta, because we use scripted to start the server to which
# scripted will send its data to.  This means that the first couple of commands
# will not be shown.
#
# To run this: bundle exec scripted -r examples/websockets.rb

dir = File.expand_path("../websockets", __FILE__)

formatter :websocket, :out => "http://localhost:9292/faye"
formatter :default
formatter :table
formatter :announcer

run "start server" do
  `bundle exec thin -e production -R #{File.join(dir, "server.ru")} -p 9292 -d start`
end

# give the server some time to start
run "sleep 1"

run "open client" do
  `bundle exec launchy http://localhost:9292/`
end

parallel do
  run "rspec"
  run "cucumber"
end

run "shutdown server" do
  `bundle exec thin -f stop`
  forced!
end
