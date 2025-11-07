# frozen_string_literal: true

module Api::V0
  class AuthController < ApiController
    skip_before_action :authenticate_user!, only: %i[signup signin refresh google_oauth2]

    def signup
      Api::V0::Auth::SignupService.call(params.to_unsafe_h) do |result|
        result.success { |data| success_response(data, status: :created) }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def google_oauth2
      Api::V0::Auth::GoogleOauth2.call(params.to_unsafe_h) do |result|
        result.success { |data| success_response(data, status: :created) }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def signin
      Api::V0::Auth::SigninService.call(params.to_unsafe_h) do |result|
        result.success { |data| success_response(data, status: :ok) }
        result.failure(:unauthorized) { unauthorized_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end

    def refresh
      Api::V0::Auth::RefreshService.call(params.to_unsafe_h) do |result|
        result.success { |data| success_response(data, status: :created) }
        result.failure(:unauthorized) { unauthorized_response }
        result.failure { |errors| unprocessable_entity(errors) }
      end
    end
  end
end
