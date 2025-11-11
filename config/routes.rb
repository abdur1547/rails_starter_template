Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    unlocks: "users/unlocks",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # API v0 routes
  draw :api_v0

  mount MissionControl::Jobs::Engine, at: "/jobs"
  get "up" => "rails/health#show", as: :rails_health_check

  root "welcome#index"
end
