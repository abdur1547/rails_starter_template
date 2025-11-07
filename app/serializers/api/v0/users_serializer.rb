# frozen_string_literal: true

module Api::V0
  class UsersSerializer < Blueprinter::Base
    identifier :id
    fields :name, :email, :uid, :avatar_url, :provider
  end
end
