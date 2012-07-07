RSpec::Matchers.define :receive do |method|

  match do |receiver|
    e = receiver.should_receive(method)
    Array(@chained).each do |chain|
      e.send(chain.keys.first, *chain.values.first)
    end
  end

  chain :with do |*args|
    @chained ||= []
    @chained << {:with => args}
  end

  chain :once do
    @chained ||= []
    @chained << {:once => []}
  end

  chain :twice do
    @chained ||= []
    @chained << {:twice => []}
  end

  chain :exectly do |n|
    @chained ||= []
    @chained << {:exactly => [n]}
  end

  chain :times do
    @chained ||= []
    @chained << {:times => []}
  end

  chain :at_least do |n|
    @chained ||= []
    @chained << {:at_least => [n]}
  end

  chain :at_most do
    @chained ||= []
    @chained << {:at_most => [n]}
  end

  chain :and_return do
    @chained ||= []
    @chained << {:and_return => [n]}
  end

  chain :never do
    @chained ||= []
    @chained << {:never => []}
  end

end
