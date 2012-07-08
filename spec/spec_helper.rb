require 'bundler/setup'
Bundler.setup

require 'support/expect_to_receive'

RSpec.configure do |config|

  config.treat_symbols_as_metadata_keys_with_true_values = true
  # config.run_all_when_everything_filtered = true
  # config.filter_run :focus
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end

require 'scripted'
