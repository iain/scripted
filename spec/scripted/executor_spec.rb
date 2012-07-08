require 'spec_helper'

describe Scripted::Executor do

  let(:delegate) { mock :delegate, :done => true, :halt => true }

  it "runs the command" do
    expect(command).to receive(:execute!)
    executor.call
  end

  it "notifies when done" do
    expect(delegate).to receive(:done).with(executor)
    executor.call
  end

  it "notifies halting", :capture do
    command { important! }
    expect(command).to receive(:execute!).and_raise(RuntimeError)
    expect(delegate).to receive(:done).with(executor)
    expect(delegate).to receive(:halt).with(executor)
    executor.call
    expect(executor).to be_halted
  end

  it "can be successful" do
    expect(executor).not_to be_success
    executor.call
    expect(executor).to be_success
  end

  it "can be failed", :capture do
    expect(command).to receive(:execute!).and_raise(RuntimeError)
    expect(executor).not_to be_failed
    executor.call
    expect(executor).to be_failed
  end

  it "won't be failed when command is unimportant", :capture do
    command { unimportant! }
    expect(command).to receive(:execute!).and_raise(RuntimeError)
    expect(executor).not_to be_failed
    executor.call
    expect(executor).not_to be_failed
  end

  it "is not started by default" do
    expect { executor.call }.to change { executor.executed? }.from(false).to(true)
  end

  it "won't execute twice" do
    expect(command).to receive(:execute!).once
    3.times { executor.execute! }
  end

  def executor(cmd = command, del = delegate)
    @executor ||= Scripted::Executor.new(cmd, del)
  end

  def command(name = "true", &block)
    @command ||= Scripted::Command.new(name, &block)
  end

end
