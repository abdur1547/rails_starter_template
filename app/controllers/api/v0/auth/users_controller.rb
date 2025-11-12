# frozen_string_literal: true

module Api::V0::Auth
  class UsersController < Api::V0::ApiController
    def show
      render json: {
        success: true,
        data: {
          user: Api::V0::UserBlueprint.render_as_hash(current_api_v0_user, view: :detailed)
        }
      }, status: :ok
    end
  end
end
