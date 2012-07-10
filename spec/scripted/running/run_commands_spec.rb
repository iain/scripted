require 'spec_helper'
require 'ostruct'

describe Scripted::Running::RunCommands do

  let(:run_commands) { Scripted::Running::RunCommands.new(configuration) }
  let(:configuration) { mock :configuration }

  def parallel_id
    @parallel_id ||= 0
    @parallel_id += 1
    @parallel_id
  end

  def run_command(options = {})
    command = OpenStruct.new({:parallel_id => parallel_id}.merge(options))
    Scripted::Running::RunCommand.new(command)
  end

  before do
    Scripted::Running::Execute.stub(:call) do |command, delegate|
      if command.failed?
        delegate.failed!(RuntimeError.new)
      else
        delegate.success!
      end
    end
  end

  context "with normal commands" do

    it "executes them all" do

      command1 = run_command
      command2 = run_command

      run_commands.run [ command1, command2 ]

      expect(command1).to be_executed
      expect(command2).to be_executed

      expect(run_commands).not_to be_failed

    end

    it "executes them all, even if one failed" do

      command1 = run_command(:failed? => true)
      command2 = run_command

      run_commands.run [ command1, command2 ]

      expect(command1).to be_executed
      expect(command2).to be_executed

      expect(run_commands).to be_failed

    end

  end

  context "with important commands" do

    it "stops executing when an important command failed" do

      command1 = run_command(:failed? => true, :important? => true)
      command2 = run_command

      run_commands.run [ command1, command2 ]

      expect(command1).to be_executed
      expect(command2).not_to be_executed

      expect(run_commands).to be_failed

    end

    it "still executes a forced command when an important command failed" do

      command1 = run_command(:failed? => true, :important? => true)
      command2 = run_command(:forced? => true)

      run_commands.run [ command1, command2 ]

      expect(command1).to be_executed
      expect(command2).to be_executed

      expect(run_commands).to be_failed

    end

  end

  context "with unimportant commands" do

    it "is still successful when unimportant command fails" do
      command1 = run_command(:failed? => true, :unimportant? => true)
      command2 = run_command

      run_commands.run [ command1, command2 ]

      expect(command1).to be_executed
      expect(command2).to be_executed

      expect(run_commands).not_to be_failed
    end

  end

  context "with only_when_failed commands" do

    it "doesn't execute only_when_failed-commands when nothing fails" do
      command1 = run_command
      command2 = run_command(:only_when_failed? => true)

      run_commands.run [ command1, command2 ]

      expect(command1).to be_executed
      expect(command2).not_to be_executed

      expect(run_commands).not_to be_failed
    end

    it "executes only_when_failed-commands when another command failed" do
      command1 = run_command(:failed? => true)
      command2 = run_command(:only_when_failed? => true)

      run_commands.run [ command1, command2 ]

      expect(command1).to be_executed
      expect(command2).to be_executed

      expect(run_commands).to be_failed
    end

  end

  # context "with parallel commands" do

  #   it "executes two commands synchronously when their parallel_ids differ" do
  #     command1 = run_command(:parallel_id => 1)
  #     command2 = run_command(:parallel_id => 2)

  #     run_commands.run [ command1, command2 ]

  #     expect(command1).not_to be_executed_at_the_same_time_as(command2)
  #   end

  #   it "executes two commands simultaniously if they share the same parallel_id" do
  #     command1 = run_command(:id => 1, :parallel_id => 1)
  #     command2 = run_command(:id => 2, :parallel_id => 1)
  #     command3 = run_command(:id => 3, :parallel_id => 2)

  #     run_commands.run [ command1, command2, command3 ]

  #     expect(command1).to be_executed_at_the_same_time_as(command2)
  #     expect(command1).not_to be_executed_at_the_same_time_as(command3)
  #     expect(command2).not_to be_executed_at_the_same_time_as(command3)
  #   end

  #   it "waits for all parallel commands to finish when the next command has a different parallel_id"

  # end

end
