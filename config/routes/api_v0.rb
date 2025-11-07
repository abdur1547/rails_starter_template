# frozen_string_literal: true

namespace :api do
  namespace :v0 do
    namespace :auth do
      post "sign_in", to: "sessions#create"
      delete "sign_out", to: "sessions#destroy"
      post "sign_up", to: "registrations#create"
      post "google", to: "google#create"
      get "user", to: "users#show"
    end
  end
end
