require 'pty'

module Scripted
  class Logger

    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
      @master_io, @slave_file = PTY.open
      @reader = Thread.new do
        @master_io.each_char do |char|
          self << char
        end
      end
      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    def self.delegate_to_formatters(name)
      define_method(name) { |*args, &block|
        sync
        send_to_formatters(name, *args, &block)
      }
    end

    delegate_to_formatters :start
    delegate_to_formatters :stop
    delegate_to_formatters :done
    delegate_to_formatters :halted
    delegate_to_formatters :execute
    delegate_to_formatters :exception

    def <<(output)
      send_to_formatters :<<, output
    end

    def to_io
      @slave_file
    end

    def send_to_formatters(*args, &block)
      formatters.each { |formatter| formatter.send(*args, &block) }
    end

    def close
      sync
      @reader.exit
      @slave_file.close
      @master_io.close
      send_to_formatters :close
    end

    private

    def sync
      @master_io.sync
      @slave_file.sync
      sleep 0.01
    end

    def formatters
      @formatters ||= build_formatters
    end

    def build_formatters
      formatter_names = configuration.formatters
      if formatter_names.empty?
        formatter_names = [ {:name => "default"} ]
      end
      formatters = formatter_names.map do |formatter|
        find_formatter(formatter[:name]).new(formatter.fetch(:out, STDERR))
      end
      formatters
    end

    def find_formatter(name)
      name = name.to_s
      if name =~ /^[A-Z]/
        require underscore(name)
        constantize(name)
      else
        require "scripted/formatters/#{name}"
        constantize("Scripted::Formatters::#{camelize(name)}")
      end
    end

    # Tries to find a constant with the name specified in the argument string:
    #
    #   "Module".constantize     # => Module
    #   "Test::Unit".constantize # => Test::Unit
    #
    # The name is assumed to be the one of a top-level constant, no matter whether
    # it starts with "::" or not. No lexical context is taken into account:
    #
    #   C = 'outside'
    #   module M
    #     C = 'inside'
    #     C               # => 'inside'
    #     "C".constantize # => 'outside', same as ::C
    #   end
    #
    # NameError is raised when the name is not in CamelCase or the constant is
    # unknown.
    def constantize(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?

      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          # Go down the ancestors to check it it's owned
          # directly before we reach Object or the end of ancestors.
          constant = constant.ancestors.inject do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end

    # Makes an underscored, lowercase form from the expression in the string.
    #
    # Changes '::' to '/' to convert namespaces to paths.
    #
    #   "ActiveModel".underscore         # => "active_model"
    #   "ActiveModel::Errors".underscore # => "active_model/errors"
    #
    # As a rule of thumb you can think of +underscore+ as the inverse of +camelize+,
    # though there are cases where that does not hold:
    #
    #   "SSLError".underscore.camelize # => "SslError"
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!('::', '/')
      # word.gsub!(/(?:([A-Za-z\d])|^)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    # By default, +camelize+ converts strings to UpperCamelCase. If the argument to +camelize+
    # is set to <tt>:lower</tt> then +camelize+ produces lowerCamelCase.
    #
    # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
    #
    #   "active_model".camelize                # => "ActiveModel"
    #   "active_model".camelize(:lower)        # => "activeModel"
    #   "active_model/errors".camelize         # => "ActiveModel::Errors"
    #   "active_model/errors".camelize(:lower) # => "activeModel::Errors"
    #
    # As a rule of thumb you can think of +camelize+ as the inverse of +underscore+,
    # though there are cases where that does not hold:
    #
    #   "SSLError".underscore.camelize # => "SslError"
    def camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end

  end
end
