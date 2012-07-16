formatter "default"
formatter "table"
formatter "announcer"

parallel do
  run "bundler" do
    `bundle update --quiet`
  end
  run "rspec" do
    `rspec -f SpecCoverage -f Fivemat`
  end
  run "cucumber"
end
# because cucumber accesses the file system, it cannot run two at the same time
run "wip" do
  `cucumber -p wip`
end
