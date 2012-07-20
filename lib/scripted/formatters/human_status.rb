module Scripted
  module Formatters
    module HumanStatus

      def human_status(command)
        translations = {
          :running                                  => "running",
          :success_ran_because_other_command_failed => "success, ran because other command failed",
          :failed_ran_because_other_command_failed  => "failed, ran because other command failed",
          :skipped_because_no_other_command_failed  => "skipped, because no other command failed",
          :failed_but_ignored                       => "failed, but ignored",
          :success                                  => "success",
          :failed_and_halted                        => "failed and halted",
          :failed                                   => "failed",
          :not_executed                             => "didn't run",
          :unknown                                  => "unknown"
        }
        translations[status_code(command)]
      end

      def status_code(command)
        case
        when command.running?                                then :running
        when command.only_when_failed? && command.success?   then :success_ran_because_other_command_failed
        when command.only_when_failed? && command.failed?    then :failed_ran_because_other_command_failed
        when command.only_when_failed? && !command.executed? then :skipped_because_no_other_command_failed
        when command.failed_but_unimportant?                 then :failed_but_ignored
        when command.success?                                then :success
        when command.halted?                                 then :failed_and_halted
        when command.failed?                                 then :failed
        when !command.executed?                              then :not_executed
        else :unknown
        end
      end

    end
  end
end
