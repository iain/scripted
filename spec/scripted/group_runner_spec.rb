require 'spec_helper'

module Scripted
  describe GroupRunner do

    let(:group) { Group.new(:default) }
    let(:configuration) { Configuration.new }

    it "runs a single group of commands" do
      cmd = nil
      group.define do
        run "echo 1" do
          cmd = self
        end
      end
      group_runner = GroupRunner.new(group, configuration)
      expect(Executor).to receive(:call).with(cmd, group_runner)
      group_runner.call
    end

    it "can fail", :capture do
      group.define do
        run "false"
      end
      group_runner = GroupRunner.call(group, configuration)
      expect(group_runner).to be_failed
    end

    it "runs only forced commands after halted", :capture do
      failing = nil
      not_run = nil
      forced = nil

      group.define do
        run "false" do
          important!
          failing = self
        end
        run "true" do
          not_run = self
        end
        run "true" do
          forced!
          forced = self
        end
      end

      expect(not_run).to receive(:execute!).never
      expect(forced).to receive(:execute!).once

      GroupRunner.call(group, configuration)
    end

  end
end
