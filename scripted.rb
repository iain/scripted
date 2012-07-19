formatter "default"
formatter "table"
formatter "announcer"

`bundle update`

parallel do
  run "rspec" do
    `rspec -f SpecCoverage -f Fivemat`
  end
  `cucumber`
end

# because cucumber accesses the file system, it cannot run two at the same time
`cucumber -p wip`
