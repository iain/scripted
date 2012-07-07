module Scripted
  module MethodObject

    def call(*args, &block)
      object = new(*args, &block)
      object.call
      object
    end

  end
end
