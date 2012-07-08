require 'spec_helper'
require 'tempfile'

describe Scripted::Commands::Shell do

  it "executes a shell command" do
    r = with_io do |io|
      shell("echo this is a test in capturing output").execute!(io)
    end
    expect(r.strip).to eq "this is a test in capturing output"
  end

  it "can succeed" do
    expect(shell("true").execute!).to be_true
  end

  it "can fail" do
    expect(shell("false").execute!).to be_false
  end

  def shell(cmd)
    @shell ||= Scripted::Commands::Shell.new(cmd)
  end

  def with_io
    file = Tempfile.new('scripted-test-log')
    yield file
    file.rewind
    file.read
  ensure
    file.close!
    file.unlink
  end


end
