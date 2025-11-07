# frozen_string_literal: true

module Api::V0::Auth
  class GoogleOauth2
    include ApplicationService

    class Contract < ApplicationContract
      params do
        required(:client_id).filled(:string)
      end
    end

    def execute(params)
      @params = params
      fetch_user_info
      yield validate_user_info
      yield create_user
      Success(json_serialize)
    end

    private

    attr_reader :params, :google_response, :user

    def fetch_user_info
      url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{params['client_id']}"
      @google_response = HTTParty.get(url)
    end

    def validate_user_info
      return Failure("uncomplete user info") unless valid_user?

      Success()
    end

    def valid_user?
      google_response["email_verified"] &&
        google_response["email"] &&
        google_response["given_name"] &&
        google_response["family_name"]
    end

    def create_user
      @user = User.from_omniauth(formate_data)
      @user ? Success(@user) : Failure(@user.error_messages)
    end

    def formate_data
      {
        info: {
          provider: "google",
          uid: google_response["email"],
          email: google_response["email"],
          avatar_url: google_response["picture"],
          name: "#{google_response['given_name']} #{google_response['family_name']}"
        }
      }
    end

    def json_serialize
      Api::V0::UsersSerializer.render_as_hash(user)
    end
  end
end
