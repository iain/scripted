require 'scripted/formatters/human_status'
require 'csv'

module Scripted
  module Formatters
    class Stats < Blank
      include HumanStatus

      def start(commands)
        @commands = commands
      end

      def close
        if out.is_a?(File)
          CSV.open(out.path, "wb", &csv)
        else
          puts CSV.generate(&csv)
        end
      end

    private

    def csv
      lambda do |csv|
        csv << ["name", "runtime", "status"]
        @commands.each do |command|
          csv << [command.name, command.runtime, human_status(command)]
        end
      end
    end

    end
  end
end
