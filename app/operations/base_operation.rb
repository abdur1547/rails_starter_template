# frozen_string_literal: true

require "dry/monads"
require "dry/validation"

class BaseOperation
  include Dry::Monads[:result, :do]

  class Result
    attr_reader :success, :value, :errors

    def initialize(success:, value: nil, errors: nil)
      @success = success
      @value = value
      @errors = errors
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    # Returns the value if success, raises if failure
    def value!
      raise "Operation failed: #{errors}" if failure?
      @value
    end

    # Returns errors or empty hash
    def errors_hash
      case errors
      when Dry::Validation::Result
        errors.errors.to_h
      when Hash
        errors
      when String
        { base: [errors] }
      else
        {}
      end
    end
  end

  class << self
    # Define an inline contract for parameter validation
    # @yield Block containing dry-validation schema definition
    def contract(&block)
      @contract_class = Class.new(Dry::Validation::Contract, &block)
    end

    # Set an external contract class for parameter validation
    # @param contract_class [Class] A Dry::Validation::Contract subclass
    def contract_class(contract_class = nil)
      if contract_class
        @contract_class = contract_class
      else
        @contract_class
      end
    end

    # Execute the operation with automatic validation
    # @param params [Hash] Parameters to validate and pass to call method
    # @return [Result] Operation result
    def call(params = {})
      new.execute(params)
    end
  end

  # Execute the operation with validation and error handling
  # @param params [Hash] Parameters to validate
  # @return [Result] Operation result
  def execute(params)
    # Validate parameters if contract is defined
    if self.class.contract_class
      validation_result = validate_params(params)
      return wrap_result(Failure(validation_result)) if validation_result.failure?
    end

    # Call the main operation logic
    result = call(params)
    wrap_result(result)
  rescue StandardError => e
    # Catch any unhandled exceptions and return as failure
    wrap_result(Failure(error: e.message, exception: e))
  end

  # Main operation logic - must be implemented by subclasses
  # @param params [Hash] Validated parameters
  # @return [Dry::Monads::Result] Success or Failure monad
  def call(params)
    raise NotImplementedError, "#{self.class} must implement #call method"
  end

  private

  # Validate parameters using the defined contract
  # @param params [Hash] Parameters to validate
  # @return [Dry::Validation::Result] Validation result
  def validate_params(params)
    contract = self.class.contract_class.new
    contract.call(params)
  end

  # Wrap a Dry::Monads::Result into BaseOperation::Result
  # @param monad_result [Dry::Monads::Result] Result monad
  # @return [Result] Wrapped result
  def wrap_result(monad_result)
    case monad_result
    when Dry::Monads::Success
      Result.new(success: true, value: monad_result.value!)
    when Dry::Monads::Failure
      failure_value = monad_result.failure
      Result.new(success: false, errors: failure_value)
    else
      # Fallback for unexpected result types
      Result.new(success: true, value: monad_result)
    end
  end
end
