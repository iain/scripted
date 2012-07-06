require 'spec_helper'

describe Scripted::Group do

  let(:group) { Scripted::Group.new("foo") }

  it "has a name" do
    expect(group.name).to eq "foo"
  end

  it "defines commands" do
    group.define do
      run "echo 1"
    end
    expect(group.commands.first.name).to eq "echo 1"
  end

end
