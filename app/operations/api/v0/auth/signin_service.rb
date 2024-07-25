# frozen_string_literal: true

module Api::V0
  module Auth
    class SigninService
      include ApplicationService

      class Contract < ApplicationContract
        params do
          required(:email).filled(:string)
          required(:password).filled(:string)
        end
      end

      def execute(params)
        @params = params

        yield fetch_user
        yield validate_password
        issue_new_tokens
        Success(json_serialize)
      end

      private

      attr_reader :params, :user, :access_token, :refresh_token

      def fetch_user
        @user = User.find_by(email: params[:email])
        return Failure(:unauthorized) unless user

        Success()
      end

      def validate_password
        return Success() if user.valid_password?(params[:password])

        Failure(:unauthorized)
      end

      def issue_new_tokens
        token_pair = Api::V0::Jwt::Issuer.call(user)
        @access_token = token_pair[:access_token]
        @refresh_token = token_pair[:refresh_token].token
      end

      def json_serialize
        {
          access_token: "#{Constants::TOKEN_TYPE} #{access_token}",
          refresh_token:
        }.to_json
      end
    end
  end
end
