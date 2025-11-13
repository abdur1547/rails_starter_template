# frozen_string_literal: true

namespace :api do
  namespace :v0 do
    scope :auth do
      post :signup, to: "auth#signup"
      post :signin, to: "auth#signin"
      post :refresh, to: "auth#refresh"
    end
  end
end
