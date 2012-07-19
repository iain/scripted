require 'csv'
require "scripted/formatters/blank"
require 'scripted/formatters/human_status'

module Scripted
  module Formatters
    class Stats < Blank
      include HumanStatus

      def stop(commands)
        if out.is_a?(File)
          CSV.open(out.path, "wb", &csv(commands))
        else
          puts CSV.generate(&csv(commands))
        end
      end

    private

    def csv(commands)
      lambda do |csv|
        csv << ["name", "runtime", "status"]
        commands.each do |command|
          csv << [command.name, command.runtime, human_status(command)]
        end
      end
    end

    end
  end
end
