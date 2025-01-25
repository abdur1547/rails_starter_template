# frozen_string_literal: true

class BaseService
  def self.call(*)
    new.call(*)
  end

  def call
    raise NotImplementedError, "Subclasses must implement a `call` method"
  end
end
