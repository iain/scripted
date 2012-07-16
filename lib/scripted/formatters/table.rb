module Scripted
  module Formatters
    class Table < Blank

      def start(commands)
        @commands = commands
      end

      def stop
        @commands.each do |command|
          puts "#{command.name} - #{command.failed?.inspect}"
        end
      end

    end
  end
end
