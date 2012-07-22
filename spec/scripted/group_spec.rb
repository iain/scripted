require 'spec_helper'

describe Scripted::Group do

  let(:group) { Scripted::Group.new("foo") }

  it "has a name" do
    expect(group.name).to eq "foo"
  end

  it "defines commands" do
    group.define do
      run "echo 1"
    end
    expect(group.commands.first.name).to eq "echo 1"
  end

  it "can define multiple parallel blocks" do
    command1 = command2 = command3 = command4 = nil

    group.define do
      parallel do
        run("one") { command1 = self }
        run("two") { command2 = self }
      end
      parallel do
        run("three") { command3 = self }
      end
      run("four") { command4 = self }
    end

    expect(command1).to be_run_in_parallel_with(command2)
    expect(command2).to be_run_in_parallel_with(command1)

    expect(command3).not_to be_run_in_parallel_with(command1)
    expect(command3).not_to be_run_in_parallel_with(command2)

    expect(command1).not_to be_run_in_parallel_with(command3)
    expect(command2).not_to be_run_in_parallel_with(command3)

    expect(command4).not_to be_run_in_parallel_with(command1)
    expect(command4).not_to be_run_in_parallel_with(command2)
    expect(command4).not_to be_run_in_parallel_with(command3)
    expect(command1).not_to be_run_in_parallel_with(command4)
    expect(command2).not_to be_run_in_parallel_with(command4)
    expect(command3).not_to be_run_in_parallel_with(command4)
  end

end
