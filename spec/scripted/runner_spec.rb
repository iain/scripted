require 'spec_helper'

module Scripted
  describe Runner do

    let(:configuration) { Configuration.new }
    let(:group_runner) { mock :group_runner, :call => true }

    before do
      GroupRunner.stub(:new) { group_runner }
    end

    it "runs default group by default" do

      default = nil
      other = nil

      configuration.evaluate do
        group :default do
          default = self
        end
        group :other do
          other = self
        end
      end

      expect(GroupRunner).to receive(:new).once.with(default, configuration)
      expect(GroupRunner).to receive(:new).never.with(other, configuration)
      runner
    end

    it "can select another group" do

      default = nil
      other = nil

      configuration.evaluate do
        group :default do
          default = self
        end
        group :other do
          other = self
        end
      end
      expect(GroupRunner).to receive(:new).never.with(default, configuration)
      expect(GroupRunner).to receive(:new).once.with(other, configuration)
      runner [:other]
    end

    it "can run multiple groups" do
      default = nil
      other = nil

      configuration.evaluate do
        group :default do
          default = self
        end
        group :other do
          other = self
        end
      end
      expect(GroupRunner).to receive(:new).with(default, configuration)
      expect(GroupRunner).to receive(:new).with(other, configuration)
      runner [ :default, :other ]
    end

    it "collects the statuses of many group runs" do
      group_runner.stub(:failed?).and_return(true)
      expect(runner).to be_failed
    end

    def runner(groups = [], conf = configuration)
      @runner ||= Runner.call(groups, conf)
    end

  end
end
