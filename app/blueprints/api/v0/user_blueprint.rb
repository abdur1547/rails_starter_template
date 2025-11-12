# frozen_string_literal: true

module Api::V0
  class UserBlueprint < BaseBlueprint
    identifier :id

    fields :email, :name, :avatar_url, :provider

    field :created_at do |user|
      user.created_at.iso8601
    end

    view :detailed do
      field :sign_in_count
      field :current_sign_in_at do |user|
        user.current_sign_in_at&.iso8601
      end
      field :last_sign_in_at do |user|
        user.last_sign_in_at&.iso8601
      end
      field :current_sign_in_ip
      field :last_sign_in_ip
      field :updated_at do |user|
        user.updated_at.iso8601
      end
    end

    view :with_token do
      field :token do |user, options|
        options[:token]
      end
    end
  end
end
