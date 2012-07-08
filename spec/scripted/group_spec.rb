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

  it "can define commands to be executed in parallel" do
    parallel_command = also_parallel = not_parallel = nil

    group.define do
      parallel do
        run("one") { parallel_command = self }
        run("two") { also_parallel    = self }
      end
      run("three") { not_parallel = self }
    end

    expect(parallel_command).to be_parallel
    expect(also_parallel).to be_parallel
    expect(not_parallel).not_to be_parallel
  end

  it "can define multiple parallel blocks" do
    command_one = command_two = command_three = self

    group.define do
      parallel do
        run("one") { command_one = self }
        run("two") { command_two = self }
      end
      parallel do
        run("three") { command_three = self }
      end
    end

    expect(command_one).to be_run_in_parallel_with(command_two)
    expect(command_one).not_to be_run_in_parallel_with(command_three)
    expect(command_two).not_to be_run_in_parallel_with(command_three)
  end

end
