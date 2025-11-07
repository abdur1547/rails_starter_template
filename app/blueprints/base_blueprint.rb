# frozen_string_literal: true

# BaseBlueprint provides common functionality for all API serializers
#
# @example Basic usage
#   class UserBlueprint < BaseBlueprint
#     identifier :id
#     fields :email, :name, :created_at
#   end
#
#   UserBlueprint.render(user)
#   UserBlueprint.render(users, root: :users)
#
# @example With associations
#   class PostBlueprint < BaseBlueprint
#     identifier :id
#     fields :title, :body
#     association :author, blueprint: UserBlueprint
#   end
#
# @example With views
#   class UserBlueprint < BaseBlueprint
#     identifier :id
#     fields :email, :name
#
#     view :detailed do
#       fields :created_at, :updated_at, :last_sign_in_at
#       association :posts, blueprint: PostBlueprint
#     end
#   end
#
#   UserBlueprint.render(user, view: :detailed)
class BaseBlueprint < Blueprinter::Base
  # Common timestamp fields helper
  def self.timestamps
    fields :created_at, :updated_at
  end

  # Helper to conditionally include fields
  # @param field_name [Symbol] Name of the field
  # @param condition [Proc] Condition to check
  def self.field_if(field_name, condition)
    field field_name, if: condition
  end
end
