# frozen_string_literal: true

module Api::V0::Auth
      # GoogleController handles Google OAuth authentication for API v0
      #
      # This endpoint accepts a Google ID token from the client (mobile app or web)
      # and exchanges it for a JWT token for API authentication.
      #
      # @example Authenticate with Google
      #   POST /api/v0/auth/google
      #   {
      #     "id_token": "google_id_token_from_client"
      #   }
      #
      # Flow:
      # 1. Client authenticates with Google and receives ID token
      # 2. Client sends ID token to this endpoint
      # 3. Server verifies token with Google
      # 4. Server creates/finds user and issues JWT
      class GoogleController < Api::V0::ApiController
        skip_before_action :authenticate_api_v0_user!

        # POST /api/v0/auth/google
        def create
          # For now, we'll accept the Google token and validate it
          # In production, you should verify the token with Google's API
          id_token = params[:id_token]

          if id_token.blank?
            render json: {
              success: false,
              error: "ID token is required"
            }, status: :unprocessable_entity
            return
          end

          # TODO: Verify the Google ID token using google-id-token gem or similar
          # For now, this is a placeholder implementation
          # user_info = verify_google_token(id_token)

          # Placeholder: In a real implementation, you would verify the token
          # and extract user information from it
          render json: {
            success: false,
            error: "Google OAuth not yet implemented. Please use the web flow at /users/auth/google_oauth2"
          }, status: :not_implemented
        end

        private

        # Verify Google ID token and return user info
        # @param id_token [String] Google ID token
        # @return [Hash] User information from Google
        def verify_google_token(id_token)
          # Implementation would use google-id-token gem or similar
          # validator = GoogleIDToken::Validator.new
          # payload = validator.check(id_token, ENV['GOOGLE_CLIENT_ID'])
          #
          # {
          #   email: payload['email'],
          #   name: payload['name'],
          #   picture: payload['picture'],
          #   provider: 'google_oauth2',
          #   uid: payload['sub']
          # }
        end

        # Find or create user from Google info
        # @param user_info [Hash] User information from Google
        # @return [User] User instance
        def find_or_create_user_from_google(user_info)
          User.where(
            provider: user_info[:provider],
            uid: user_info[:uid]
          ).first_or_create! do |user|
            user.email = user_info[:email]
            user.name = user_info[:name]
            user.avatar_url = user_info[:picture]
            user.password = Devise.friendly_token[0, 20]
          end
        end
      end
end
