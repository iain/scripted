parallel do
  run "rspec"
  run "cucumber"
end
# because cucumber access the file system, it cannot run two at the same time
run "wip" do
  `cucumber -p wip`
end
