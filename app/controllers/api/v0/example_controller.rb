# frozen_string_literal: true

module Api::V0
  class ExampleController < ApiController
    def index
      render json: { status: :ok, user: @current_user }, status: :ok
    end
  end
end
