require 'bundler/setup'
Bundler.setup

require 'support/expect_to_receive'
require 'support/io_capture'

RSpec.configure do |config|

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end

require 'scripted'
