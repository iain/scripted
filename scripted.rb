parallel do
  run "bundle update"
  run "rspec -f SpecCoverage -f Fivemat"
  run "cucumber"
end
# because cucumber access the file system, it cannot run two at the same time
run "wip" do
  `cucumber -p wip`
end
