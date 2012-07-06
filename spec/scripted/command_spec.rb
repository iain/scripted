require 'spec_helper'

describe Scripted::Command do

  it "has a name" do
    command = Scripted::Command.new("foo")
    expect(command.name).to eq "foo"
  end

  it "uses the name as shell function if no other command was specified" do
    command = Scripted::Command.new("foo")
    expect(command.execute).to eq "foo"
  end

  specify "the sh method overrides the command to be run" do
    command = Scripted::Command.new("foo") do
      sh "bar"
    end
    expect(command.execute).to eq "bar"
  end

end
