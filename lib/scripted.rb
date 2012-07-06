require "scripted/version"
require "scripted/group"
require "scripted/command"
require "scripted/runner"

module Scripted

  def self.run(group_names)
    Runner.call(groups.values_at(*group_names.map(&:to_s)))
  end

  def self.group(name, &block)
    groups[name].define(&block)
  end

  def self.groups
    @groups ||= Hash.new { |hash, key| hash[key.to_s] = Group.new(key) }
  end

end
