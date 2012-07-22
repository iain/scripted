# Taken from Minitest's Pride formatter
# Meant as example of custom formatters

require "scripted/formatters/blank"

class Pride < Scripted::Formatters::Blank

  PI_3 = Math::PI / 3

  def initialize(*)
    super
    @index  = 0
    @colors = (0...(6 * 7)).map { |n|
      n *= 1.0 / 6
      r  = (3 * Math.sin(n           ) + 3).to_i
      g  = (3 * Math.sin(n + 2 * PI_3) + 3).to_i
      b  = (3 * Math.sin(n + 4 * PI_3) + 3).to_i
      36 * r + 6 * g + b + 16
    }
    @size   = @colors.size
  end

  def each_char(char, command)
    print pride(char)
  end

  def pride(string)
    color = @colors[@index % @size]
    @index += 1
    "\e[38;5;#{color}m#{string}\e[0m"
  end
end

formatter Pride

run "rspec --no-color"
run "cucumber -p no-color"
