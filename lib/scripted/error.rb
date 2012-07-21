module Scripted
  class Error < RuntimeError
  end

  class RunningFailed < Error
  end

  class CommandFailed < Error
  end

  class NotConfigured < Error
  end
end
