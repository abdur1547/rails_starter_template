# frozen_string_literal: true

module Api::V0::Auth
  class SessionsController < Api::V0::ApiController
    skip_before_action :authenticate_api_v0_user!, only: [ :create ]

    def create
      user = User.find_for_database_authentication(email: sign_in_params[:email])

      if user&.valid_password?(sign_in_params[:password])
        sign_in(:user, user, store: false)
        render json: {
          success: true,
          message: "Signed in successfully",
          data: {
            user: Api::V0::UserBlueprint.render_as_hash(user, view: :with_token)
          }
        }, status: :ok
      else
        render json: {
          success: false,
          error: "Invalid email or password"
        }, status: :unauthorized
      end
    end

    def destroy
      if current_api_v0_user
        sign_out(current_api_v0_user)
        render json: {
          success: true,
          message: "Signed out successfully"
        }, status: :ok
      else
        render json: {
          success: false,
          error: "You are not signed in"
        }, status: :unauthorized
      end
    end

    private

    def sign_in_params
      params.permit(:email, :password)
    end
  end
end
