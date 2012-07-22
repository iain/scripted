Then /^it should pass$/ do
  assert_success true
end

Then /^it should fail$/ do
  assert_success false
end

Given /^the configuration:$/ do |string|
  write_file "scripted.rb", string
end

Then /^it should have taken about (\d+) seconds$/ do |seconds|
  last_line = all_output.split("\n").reject { |line| line =~ /^\s*$/ }.last.strip
  total = /Total runtime: (\d+\.\d+)s/.match(last_line)
  expect(total[1].to_f).to be_within(0.5).of(seconds.to_f)
end

When /^I run scripted$/ do
  run_simple "scripted", false
end

Then /^the file "(.*?)" should contain:$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end
