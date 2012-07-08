parallel do
  run "rspec"
  run "cucumber"
  run "wip" do
    sh "cucumber -p wip"
  end
end
