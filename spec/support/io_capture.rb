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

  def with_io
    read, write = IO.pipe
    text = ""
    thread = Thread.new do
      read.each_char do |char|
        text << char
      end
    end
    yield write
    read.sync
    sleep 0.01
    thread.terminate
    text
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
