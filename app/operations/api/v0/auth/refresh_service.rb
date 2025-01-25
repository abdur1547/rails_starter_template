# frozen_string_literal: true

module Api::V0
  module Auth
    class RefreshService
      include ApplicationService

      class Contract < ApplicationContract
        params do
          required(:access_token).filled(:string)
          required(:refresh_token).filled(:string)
        end
      end

      def execute(params)
        @params = params
        yield validate_access_token
        yield fetch_user
        yield validate_refresh_token
        blacklist_previoud_access_token
        Success(json_serialize)
      end

      private

      attr_reader :params, :user, :decoded_token

      def validate_access_token
        access_token = params[:access_token].split("Bearer ")&.last
        @decoded_token = Jwt::Decoder.call(access_token:, verify: false)
        return Failure(:unauthorized) if decoded_token.nil?

        Success()
      end

      def fetch_user
        @user = User.find_by(id: decoded_token[:user_id])
        return Failure(:unauthorized) unless user

        Success()
      end

      def validate_refresh_token
        existing_refresh_token = user.refresh_tokens.find_by_token(params[:refresh_token]) # rubocop:disable Rails/DynamicFindBy

        return Failure(:unauthorized) unless existing_refresh_token

        return Failure(:unauthorized) unless existing_refresh_token.exp > Time.now.utc

        Success()
      end

      def blacklist_previoud_access_token
        Jwt::Blacklister.blacklist!(jti: decoded_token[:jti], user:)
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
