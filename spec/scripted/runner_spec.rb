require 'spec_helper'

describe Scripted::Runner do

  it "runs groups of commands" do
    groups = [ Scripted::Group.new("a") ]
    Scripted::Runner.call(groups)
  end

end
