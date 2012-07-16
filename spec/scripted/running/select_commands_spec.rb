require 'spec_helper'

describe Scripted::Running::SelectCommands do

  let(:command1) { mock }
  let(:command2) { mock }
  let(:group1) { mock :commands => [command1] }
  let(:group2) { mock :commands => [command2] }

  let(:logger) { mock(:logger).as_null_object }

  it "selects the groups you named" do
    groups = { :one => group1, :two => group2 }
    configuration = mock :groups => groups
    select_commands = Scripted::Running::SelectCommands.new(configuration, logger)
    commands = select_commands.commands([:one]) 
    expect(commands.map(&:command)).to eq [command1]
  end

  it "selects the default group when you don't give any names" do
    groups = { :one => group1, :default => group2 }
    configuration = mock :groups => groups
    select_commands = Scripted::Running::SelectCommands.new(configuration, logger)
    commands = select_commands.commands([]) 
    expect(commands.map(&:command)).to eq [command2]
  end

end
