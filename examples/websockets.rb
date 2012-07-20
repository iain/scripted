# This is an example of using the websockets formatter.
#
# The web application is made with Ember.js. Also, even though some commands
# might run in parallel, their output will appear properly in the web view.
#
# To run this: rake examples:websockets

dir = File.expand_path("../websockets", __FILE__)

formatter :default
formatter :table

run "start server" do
  `bundle exec thin -e production -R #{File.join(dir, "server.ru")} -p 9292 -d start`
end

# give the server some time to start
run "sleep 1"

# opens the web page with the ember.js app
run "open client" do
  `bundle exec launchy http://localhost:9292/`
end

# how unbelievable meta! :)
run "scripted with websocket formatter" do
  `bundle exec scripted -f websocket -o http://localhost:9292/faye`
end

# keep the connection open for just a bit longer
run "sleep 1"

# forcefully shut down, because websocket connections will cause a timeout anyway
run "shutdown server" do
  `bundle exec thin -f stop`
  forced!
end
