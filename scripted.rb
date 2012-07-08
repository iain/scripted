parallel do
  run "rspec"
  run "cucumber"
  run "wip" do
    `cucumber -p wip`
  end
end
