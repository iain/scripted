require 'spec_helper'

describe Scripted::Configuration do

  it "can define groups" do
    subject.group :foo
    subject.group :bar
    expect(subject).to have(2).groups
  end

  it "defines commands on the default group" do
    subject.run "foo"
    expect(subject).to have(1).groups
  end

  it "handles non existing files" do
    subject.config_file "non-existing.rb"
    expect { subject.load_files }.to raise_error Scripted::ConfigFileNotFound
  end

  it "adds the default file on demand" do
    expect {
      subject.with_default_config_file!
    }.to change { subject.config_files }.to ["scripted.rb"]
  end

  it "does not allow setting out without a formatter" do
    expect { subject.out "foo" }.to raise_error Scripted::NoFormatterForOutput
  end

  it "changes the last formatter to use a different output" do
    subject.formatter :table, :out => "old.log"
    expect { subject.out "new.log" }.to change { subject.formatters.first[:out] }.to "new.log"
  end

  it "can set multple formatter" do
    subject.formatter :table, :out => "old.log"
    subject.formatter :websocket
    expect(subject).to have(2).formatters
  end

  it "reraises all configuration errors so they are easily rescued" do
    expect {
      subject.evaluate do
        fooasdad
      end
    }.to raise_error Scripted::ConfigurationSyntaxError
  end

end
