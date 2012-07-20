require 'tempfile'

module IOCapture

  def with_io
    file = Tempfile.new('scripted-test-log')
    yield file
    file.rewind
    file.read
  ensure
    file.close!
    file.unlink
  end

  def capture
    stdout = StringIO.new
    stderr = StringIO.new
    $stdout = stdout
    $stderr = stderr
    yield
    stdout.rewind
    stderr.rewind
    [ stdout, stderr ]
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end

end

RSpec.configure do |config|

  config.include IOCapture

end
