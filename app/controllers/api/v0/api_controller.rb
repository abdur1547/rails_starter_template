# frozen_string_literal: true

module Api::V0
  class ApiController < ActionController::API
    include ErrorHandler

    before_action :authenticate_user!

    private

    def authenticate_user!
      current_user, decoded_token = Jwt::Authenticator.call(
        headers: request.headers
      )

      @current_user = current_user
      @decoded_token = decoded_token
    end
  end
end
