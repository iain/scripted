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

  attr_reader :stdout, :stderr

  def capture_out
    $stderr = StringIO.new
    $stdout = StringIO.new
    yield
  ensure
    $stdout.rewind
    $stderr.rewind
    @stdout = $stdout.read
    @stderr = $stderr.read
    $stdout = STDOUT
    $stderr = STDERR
    if example.exception
      STDOUT.puts stdout if stdout != ""
      STDERR.puts stderr if stderr != ""
    end
  end

end

RSpec.configure do |config|

  config.include IOCapture

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.around :each, :capture => true do |example|
    capture_out { example.call }
  end

end
