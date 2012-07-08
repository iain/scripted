require 'spec_helper'
require 'tempfile'

describe Scripted::Commands::Shell do

  it "executes a shell command" do
    shell = Scripted::Commands::Shell.new("echo this is a test in capturing output")
    r = with_io do |io|
      shell.execute!(io)
    end
    expect(r.strip).to eq "this is a test in capturing output"
  end

  it "can fail" do
    shell = Scripted::Commands::Shell.new("false")
    expect{shell.execute!}.to raise_error Scripted::CommandFailed
  end

end
