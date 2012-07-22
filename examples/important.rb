formatter :table
formatter :announcer
formatter :default

run "an unimportant failing command" do
  `false`
  unimportant!
end

run "a normal command" do
  `echo You should see this output`
end

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

run "this runs because it failed" do
  `true`
  only_when_failed!
end
