RSpec::Matchers.define :receive do |method|

  match do |receiver|
    e = receiver.should_receive(method)
    Array(@chained).each do |chain|
      e.send(*chain)
    end
  end

  %w(with once twice exactly at_least times at_most and_return never and_raise).each do |cmd|
    chain cmd do |*args|
      @chained ||= []
      @chained << [cmd, *args]
    end
  end

end
