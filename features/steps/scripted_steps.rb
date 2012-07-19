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
  real = /\b(\d+\.\d+)\sreal\b/.match(all_output) { |m| m[1].to_f }
  expect(real).to be_a(Float), "Couldn't find real time in output:\n\n#{all_output}"
  expect(real).to be_within(0.5).of(seconds.to_f)
end

When /^I run scripted$/ do
  run_simple "scripted", false
end

Then /^the file "(.*?)" should contain:$/ do |file, partial_content|
  check_file_content(file, partial_content, true)
end
