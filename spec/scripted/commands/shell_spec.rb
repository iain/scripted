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

  it "should remind me to remove the childprocess patch in a newer version" do
    require 'childprocess/version'
    # this spec must be removed when my Pull Request is merged and released.
    # if a newer version of the gem is released
    if ChildProcess::VERSION == "0.3.3"
      pending "waiting for my pull request to be released"
    else
      fail "is my pull request merge yet?"
    end
  end

end
