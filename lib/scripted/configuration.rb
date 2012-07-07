module Scripted

  class ConfigurationError       < Error;              end
  class NoFormatterForOutput     < ConfigurationError; end
  class ConfigFileNotFound       < ConfigurationError; end
  class ConfigurationSyntaxError < ConfigurationError; end

  class Configuration

    # Defines a group
    def group(name, &block)
      groups[name].define(&block)
    end

    # Defines a command in the `:default` group.
    def run(name, &block)
      groups[:default].define { run(name, &block) }
    end

    # Makes a parallel block inside the `:default` group.
    def parallel(&block)
      groups[:default].define { parallel(&block) }
    end

    def formatter(name, options = {})
      formatters << options.merge(:name => name)
    end

    def out(out)
      if formatters.any?
        formatters.last[:out] = out
      else
        fail NoFormatterForOutput, "You must first specify a formatter to use this option"
      end
    end

    def formatters
      @formatters ||= []
    end

    def config_file(*file_names)
      file_names.each do |file_name|
        config_files << file_name
      end
    end

    def config_files
      @config_files ||= []
    end

    def absolute_config_files
      config_files.map { |file_name| File.expand_path(file_name) }.uniq
    end

    def groups
      @groups ||= Hash.new { |hash, key| hash[key] = Group.new(key) }
    end

    def select_groups(*group_names)
      groups.values_at(*group_names.map(&:to_sym))
    end

    def with_default_config_file!
      config_file "scripted.rb" if config_files.empty?
    end

    def load_files
      absolute_config_files.each do |file_name|
        load_file(file_name)
      end
    end

    def load_file(file_name)
      source = File.open(file_name, 'r:utf-8').read
      evaluate source, file_name, 1
    rescue Errno::ENOENT => error
      raise ConfigFileNotFound, "No such file -- #{file_name}\nEither create a file called 'scripted.rb', or specify another file to load"
    end

    def evaluate(*args, &block)
      instance_eval(*args, &block)
    rescue Exception => error
      my_error = ConfigurationSyntaxError.new("#{error.message} (#{error.class})")
      my_error.set_backtrace error.backtrace
      raise my_error
    end

  end

end
