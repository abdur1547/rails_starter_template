# frozen_string_literal: true

module Api::V0
  module Auth
    class RefreshService
      include ApplicationService

      class Contract < ApplicationContract
        params do
          required(:refresh_token).filled(:string)
        end
      end

      def execute(params)
        @params = params
        yield validate_refresh_token
        Success(json_serialize)
      end

      private

      attr_reader :params, :user, :decoded_token

      def validate_refresh_token
        refresh_token = RefreshToken.find_by_token(params[:refresh_token]) # rubocop:disable Rails/DynamicFindBy
        return Failure(:unauthorized) unless refresh_token
        @user = User.find_by(id: refresh_token.user_id)
        return Failure(:unauthorized) unless user

        Success()
      end

      def new_access_token
        token = Jwt::Encoder.call(user).first
        "#{Constants::TOKEN_TYPE} #{token}"
      end

      def json_serialize
        {
          access_token: new_access_token
        }
      end
    end
  end
end
