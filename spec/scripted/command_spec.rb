require 'spec_helper'

describe Scripted::Command do

  let(:command) { Scripted::Command.new("foo") }

  it "has a name" do
    expect(command.name).to eq "foo"
  end

  it "uses the name as shell function if no other command was specified" do
    expect(command.executable).to be_a Scripted::Commands::Shell
  end

  specify "the sh method overrides the command to be run" do
    command.define do
      sh "bar"
    end
    expect(command.executable).to be_a Scripted::Commands::Shell
  end

  specify "the backtics also do a shell command" do
    command.define do
      `bar`
    end
    expect(command.executable).to be_a Scripted::Commands::Shell
  end

  specify "the rake method overrides the command to be run" do
    command.define do
      rake "db:migrate"
    end
    expect(command.executable).to be_a Scripted::Commands::Rake
  end

  specify "the ruby method stores a block" do
    command.define do
      ruby { 1 + 1 }
    end
    expect(command.executable).to be_a Scripted::Commands::Ruby
  end

  it "can be important" do
    expect(command).not_to be_important
    command.important!
    expect(command).to be_important
  end

  it "can be unimportant" do
    expect(command).not_to be_unimportant
    command.unimportant!
    expect(command).to be_unimportant
  end

  it "can be forced" do
    expect(command).not_to be_forced
    command.forced!
    expect(command).to be_forced
  end

  it "can be only when failed" do
    expect(command).not_to be_only_when_failed
    command.only_when_failed!
    expect(command).to be_only_when_failed
  end

  it "can be only when success" do
    expect(command).not_to be_only_when_success
    command.only_when_success!
    expect(command).to be_only_when_success
  end

  it "can be parallel" do
    command = Scripted::Command.new("true", :parallel_id => 10)
    expect(command.parallel_id).to eq 10
  end

end
