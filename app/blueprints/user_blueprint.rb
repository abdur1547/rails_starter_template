# frozen_string_literal: true

# UserBlueprint serializes User model for API responses
#
# @example Basic user info
#   UserBlueprint.render(user)
#   # => {"id":1,"email":"user@example.com","name":"John Doe"}
#
# @example With detailed view
#   UserBlueprint.render(user, view: :detailed)
#   # Includes timestamps and sign-in info
#
# @example With auth token
#   UserBlueprint.render(user, view: :with_token, token: jwt_token)
#   # Includes JWT token for API authentication
#
# @example Collection with root
#   UserBlueprint.render(users, root: :users)
#   # => {"users":[{...},{...}]}
class UserBlueprint < BaseBlueprint
  # Primary identifier
  identifier :id

  # Basic fields (always included)
  fields :email, :name

  # Detailed view - includes timestamps and tracking info
  view :detailed do
    fields :created_at, :updated_at
    field :sign_in_count, name: :total_sign_ins
    field :current_sign_in_at, name: :last_sign_in
    field :provider
  end

  # Profile view - includes avatar and personal info
  view :profile do
    fields :name, :email, :avatar_url, :created_at
    field :member_since do |user|
      "Member since #{user.created_at&.strftime('%B %Y')}"
    end
  end

  # Auth view - includes JWT token for authentication
  view :with_token do
    fields :id, :email, :name
    field :token do |_user, options|
      options[:token]
    end
    field :token_type do
      "Bearer"
    end
    field :expires_in do |_user, options|
      options[:expires_in] || (24 * 60 * 60) # Default 24 hours in seconds
    end
  end

  # Minimal view - just id and name
  view :minimal do
    fields :id, :name
  end
end
