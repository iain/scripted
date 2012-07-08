require 'spec_helper'
require 'scripted/formatters/websocket'

describe Scripted::Formatters::Websocket do

  it "uses websocket" do
    pending "this test just puts the output for the moment"
    command = Scripted::Commands::Shell.new(%~ruby -e "20.times { |i| print i; sleep 0.1 }"~)
    Scripted::Formatters::Websocket.new("ws://....") do |log|
      command.execute!(log)
    end
  end

end
