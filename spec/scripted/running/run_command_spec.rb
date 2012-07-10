require 'spec_helper'

describe Scripted::Running::RunCommand do

  let(:command)  { stub(:command, :unimportant? => false, :forced? => false, :important? => false, :only_when_failed? => false) }
  let(:delegate) { mock :stub, :done => true, :halt! => true }
  subject(:run_command) { Scripted::Running::RunCommand.new(command) }

  def run
    run_command.execute!(delegate)
  end

  context "when a command runs successfully" do

    before do
      Scripted::Running::Execute.stub :call do |command, delegate|
        delegate.success!
      end
    end

    it "notifies the delegate" do
      expect(delegate).to receive(:done).once.with(run_command)
      expect(delegate).to receive(:halt!).never
      run
    end

    it "should be successful" do
      run
      expect(run_command).to be_success
    end

    it "should have executed" do
      run
      expect(run_command).to be_executed
    end

    it "should not be running" do
      run
      expect(run_command).not_to be_running
    end

    it "should not have halted" do
      run
      expect(run_command).not_to be_halted
    end

    it "should not have failed" do
      run
      expect(run_command).not_to be_failed
    end

    it "should have no exception" do
      run
      expect(run_command).not_to be_nil
    end

    it "should not be failed but unimportant" do
      run
      expect(run_command).not_to be_failed_but_unimportant
    end

  end

  context "when a normal command fails" do

    before do
      Scripted::Running::Execute.stub :call do |command, delegate|
        delegate.failed!(exception)
      end
    end

    let(:exception) { RuntimeError.new("OH NOES") }

    it "notifies the delegate" do
      expect(delegate).to receive(:done).with(run_command)
      run
    end

    it "should not be successful" do
      run
      expect(run_command).not_to be_success
    end

    it "should have executed" do
      run
      expect(run_command).to be_executed
    end

    it "should not be running" do
      run
      expect(run_command).not_to be_running
    end

    it "should have failed" do
      run
      expect(run_command).to be_failed
    end

    it "should not have halted" do
      run
      expect(run_command).not_to be_halted
    end

    it "should have a exception" do
      run
      expect(run_command).not_to be exception
    end

    it "should not be failed but unimportant" do
      run
      expect(run_command).not_to be_failed_but_unimportant
    end

    context "when the command is important" do

      before do
        command.stub(:important?).and_return(true)
      end

      it "should tell the delegate to halt" do
        expect(delegate).to receive(:halt!)
        run
      end

      it "should be halted" do
        run
        expect(run_command).to be_halted
      end

    end

    context "when the command is unimportant" do

      before do
        command.stub(:unimportant?).and_return(true)
      end

      it "should be unimportant" do
        expect(run_command).to be_unimportant
      end

      it "should not be failed" do
        run
        expect(run_command).not_to be_failed
      end

      it "should be failed but important" do
        run
        expect(run_command).to be_failed_but_unimportant
      end

    end

  end

end
