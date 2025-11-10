# frozen_string_literal: true

module Api::V0
  class ApiController < ActionController::API
    include ErrorHandler
  end
end
