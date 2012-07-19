module Scripted
  module Formatters
    module HumanStatus

      def human_status(command)
        case
        when command.only_when_failed? && command.success?   then "success because something failed"
        when command.only_when_failed? && command.failed?    then "failed because something failed"
        when command.only_when_failed? && !command.executed? then "skipped because nothing failed"
        when command.failed_but_unimportant? then "failed, but ignored"
        when command.success?   then "success"
        when command.halted?    then "failed and halted"
        when command.failed?    then "failed"
        when !command.executed? then "didn't run"
        else "unknown"
        end
      end

    end
  end
end
