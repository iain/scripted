parallel do
  run "bundle exec rspec --format progress"
  run "bundle exec cucumber --format progress"
end
