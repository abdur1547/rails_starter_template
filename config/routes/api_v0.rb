# frozen_string_literal: true

namespace :api do
  namespace :v0 do
    get "api_status", to: "example#index"

    scope :auth do
      post :signup, to: "auth#signup"
      post :signin, to: "auth#signin"
      post :refresh, to: "auth#refresh"
      post :google_oauth2, to: "auth#google_oauth2"
    end
  end
end
