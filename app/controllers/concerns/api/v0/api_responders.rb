# frozen_string_literal: true

module Api::V0
    # ApiResponders provides helper methods for formatting API responses
    #
    # @example Success response
    #   render_success(user, serializer: UserBlueprint)
    #
    # @example Error response
    #   render_error("Invalid credentials", :unauthorized)
    #
    # @example JWT authentication response
    #   render_auth_success(user, token)
    module ApiResponders
      extend ActiveSupport::Concern

      private

      # Renders a successful response with data
      # @param data [Object] Data to serialize
      # @param serializer [Class] Blueprint serializer class
      # @param status [Symbol] HTTP status symbol
      # @param options [Hash] Additional options for serializer
      def render_success(data, serializer:, status: :ok, **options)
        render json: {
          success: true,
          data: serializer.render_as_hash(data, **options)
        }, status: status
      end

      # Renders an error response
      # @param message [String] Error message
      # @param status [Symbol] HTTP status symbol
      # @param errors [Hash] Additional error details
      def render_error(message, status = :unprocessable_entity, errors: {})
        render json: {
          success: false,
          error: message,
          errors: errors
        }, status: status
      end

      # Renders authentication success with user and token
      # @param user [User] Authenticated user
      # @param token [String] JWT token (extracted from headers)
      def render_auth_success(user, token = nil)
        # Token is automatically added to Authorization header by devise-jwt
        # We'll extract it from response headers if needed
        render json: {
          success: true,
          message: "Authentication successful",
          data: {
            user: Api::V0::UserBlueprint.render_as_hash(user)
          }
        }, status: :ok
      end

      # Renders authentication failure
      # @param message [String] Error message
      def render_auth_error(message = "Authentication failed")
        render_error(message, :unauthorized)
      end
    end
end
