# frozen_string_literal: true

module Api::V0::Auth
      class RegistrationsController < BaseController
        skip_before_action :authenticate_api_v0_user!, only: [ :create ]

        # POST /api/v0/auth/sign_up
        def create
          user = User.new(sign_up_params)

          if user.save
            sign_in(:user, user, store: false)
            render json: {
              success: true,
              message: "Signed up successfully",
              data: {
                user: Api::V0::UserBlueprint.render_as_hash(user)
              }
            }, status: :created
          else
            render json: {
              success: false,
              error: "Registration failed",
              errors: user.errors.messages
            }, status: :unprocessable_entity
          end
        end

        private

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation, :name)
        end
      end
end
