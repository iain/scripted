require 'spec_helper'

describe Scripted::Commands::Ruby do

  it "evaluates a block" do
    ruby = Scripted::Commands::Ruby.new(lambda { 1 })
    expect(ruby.execute!).to eq 1
  end

end
