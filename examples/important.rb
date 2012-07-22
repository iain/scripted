formatter :table
formatter :announcer
formatter :default

run "an important failing command" do
  `false`
  important!
end

run "another normal command" do
  `echo You should never see this`
end

run "a forced command" do
  `true`
  forced!
end

run "a command that executes because the second command failed" do
  `true`
  only_when_failed!
end
