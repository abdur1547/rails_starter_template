# frozen_string_literal: true

module Api::V0
    class BaseController < ActionController::API
      include ApiResponders

      before_action :authenticate_api_v0_user!

      respond_to :json

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

      # Authenticate user for API v0 using JWT
      def authenticate_api_v0_user!
        unless current_api_v0_user
          render_auth_error("You need to sign in or sign up before continuing.")
        end
      end

      # Current authenticated user for API v0
      def current_api_v0_user
        @current_api_v0_user ||= warden.authenticate(scope: :user, store: false)
      end

      # Helper to access warden
      def warden
        request.env["warden"]
      end

      # Handle record not found errors
      def not_found(exception)
        render_error(exception.message, :not_found)
      end

      # Handle validation errors
      def unprocessable_entity(exception)
        render_error(
          exception.message,
          :unprocessable_entity,
          errors: exception.record&.errors&.messages || {}
        )
      end
    end
end
