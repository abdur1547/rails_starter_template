# frozen_string_literal: true

require "rails_helper"

RSpec.describe BaseOperation do
  # Test operation with inline contract
  class TestOperationWithContract < BaseOperation
    contract do
      params do
        required(:name).filled(:string)
        required(:age).filled(:integer, gt?: 0)
      end
    end

    def call(params)
      Success(user: params[:name], age: params[:age])
    end
  end

  # Test operation without contract
  class TestOperationWithoutContract < BaseOperation
    def call(params)
      if params[:value].to_i > 0
        Success(result: params[:value] * 2)
      else
        Failure("Value must be positive")
      end
    end
  end

  # Test operation with multiple steps
  class TestMultiStepOperation < BaseOperation
    include Dry::Monads[:result, :do]

    def call(params)
      step1 = yield step_one(params[:value])
      step2 = yield step_two(step1)
      step3 = yield step_three(step2)
      Success(result: step3)
    end

    private

    def step_one(value)
      value > 0 ? Success(value * 2) : Failure("Step 1 failed")
    end

    def step_two(value)
      value < 100 ? Success(value + 10) : Failure("Step 2 failed: value too large")
    end

    def step_three(value)
      Success(value * 3)
    end
  end

  # Test operation that raises exception
  class TestOperationWithException < BaseOperation
    def call(params)
      raise StandardError, "Something went wrong" if params[:trigger_error]
      Success(ok: true)
    end
  end

  describe ".call" do
    context "with contract validation" do
      it "returns success when params are valid" do
        result = TestOperationWithContract.call(name: "John", age: 30)

        expect(result).to be_success
        expect(result.value).to eq(user: "John", age: 30)
      end

      it "returns failure when required param is missing" do
        result = TestOperationWithContract.call(name: "John")

        expect(result).to be_failure
        expect(result.errors_hash).to have_key(:age)
      end

      it "returns failure when param type is invalid" do
        result = TestOperationWithContract.call(name: "John", age: "thirty")

        expect(result).to be_failure
        expect(result.errors_hash).to have_key(:age)
      end

      it "returns failure when validation rule fails" do
        result = TestOperationWithContract.call(name: "John", age: -5)

        expect(result).to be_failure
        expect(result.errors_hash).to have_key(:age)
      end
    end

    context "without contract validation" do
      it "returns success when operation succeeds" do
        result = TestOperationWithoutContract.call(value: 5)

        expect(result).to be_success
        expect(result.value).to eq(result: 10)
      end

      it "returns failure when operation fails" do
        result = TestOperationWithoutContract.call(value: -5)

        expect(result).to be_failure
        expect(result.errors).to eq("Value must be positive")
      end
    end

    context "with multiple steps" do
      it "executes all steps and returns success" do
        result = TestMultiStepOperation.call(value: 10)

        expect(result).to be_success
        # (10 * 2 + 10) * 3 = 90
        expect(result.value).to eq(result: 90)
      end

      it "stops at first failing step" do
        result = TestMultiStepOperation.call(value: 50)

        expect(result).to be_failure
        expect(result.errors).to eq("Step 2 failed: value too large")
      end

      it "returns failure when first step fails" do
        result = TestMultiStepOperation.call(value: -1)

        expect(result).to be_failure
        expect(result.errors).to eq("Step 1 failed")
      end
    end

    context "with exceptions" do
      it "catches exceptions and returns failure" do
        result = TestOperationWithException.call(trigger_error: true)

        expect(result).to be_failure
        expect(result.errors).to be_a(Hash)
        expect(result.errors[:error]).to eq("Something went wrong")
      end

      it "returns success when no exception is raised" do
        result = TestOperationWithException.call(trigger_error: false)

        expect(result).to be_success
        expect(result.value).to eq(ok: true)
      end
    end
  end

  describe BaseOperation::Result do
    describe "#success?" do
      it "returns true for success result" do
        result = BaseOperation::Result.new(success: true, value: "data")
        expect(result.success?).to be true
      end

      it "returns false for failure result" do
        result = BaseOperation::Result.new(success: false, errors: "error")
        expect(result.success?).to be false
      end
    end

    describe "#failure?" do
      it "returns false for success result" do
        result = BaseOperation::Result.new(success: true, value: "data")
        expect(result.failure?).to be false
      end

      it "returns true for failure result" do
        result = BaseOperation::Result.new(success: false, errors: "error")
        expect(result.failure?).to be true
      end
    end

    describe "#value!" do
      it "returns value for success result" do
        result = BaseOperation::Result.new(success: true, value: "data")
        expect(result.value!).to eq("data")
      end

      it "raises error for failure result" do
        result = BaseOperation::Result.new(success: false, errors: "error")
        expect { result.value! }.to raise_error(RuntimeError, /Operation failed/)
      end
    end

    describe "#errors_hash" do
      it "returns empty hash for success result" do
        result = BaseOperation::Result.new(success: true, value: "data")
        expect(result.errors_hash).to eq({})
      end

      it "converts string error to hash" do
        result = BaseOperation::Result.new(success: false, errors: "Something failed")
        expect(result.errors_hash).to eq(base: [ "Something failed" ])
      end

      it "returns hash errors as-is" do
        errors = { email: [ "is invalid" ], name: [ "can't be blank" ] }
        result = BaseOperation::Result.new(success: false, errors: errors)
        expect(result.errors_hash).to eq(errors)
      end

      it "converts validation result errors to hash" do
        validation = TestOperationWithContract.new.send(:validate_params, { name: "John" })
        result = BaseOperation::Result.new(success: false, errors: validation)
        expect(result.errors_hash).to have_key(:age)
      end
    end
  end

  describe "dry-monads integration" do
    let(:operation) { TestOperationWithoutContract.new }

    it "includes Success monad" do
      result = operation.instance_eval { Success(data: "value") }
      expect(result).to be_a(Dry::Monads::Success)
      expect(result.value!).to eq(data: "value")
    end

    it "includes Failure monad" do
      result = operation.instance_eval { Failure("error message") }
      expect(result).to be_a(Dry::Monads::Failure)
      expect(result.failure).to eq("error message")
    end
  end

  describe "contract definition" do
    it "allows inline contract definition" do
      expect(TestOperationWithContract.contract_class).not_to be_nil
      expect(TestOperationWithContract.contract_class.superclass).to eq(Dry::Validation::Contract)
    end

    it "returns nil when no contract is defined" do
      expect(TestOperationWithoutContract.contract_class).to be_nil
    end
  end

  describe "#call" do
    it "must be implemented by subclasses" do
      operation = Class.new(BaseOperation).new
      expect { operation.call({}) }.to raise_error(NotImplementedError)
    end
  end
end
