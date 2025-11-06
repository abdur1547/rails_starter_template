# frozen_string_literal: true

# ErrorBlueprint serializes error responses for API
#
# @example Single error
#   ErrorBlueprint.render_as_hash(message: "Not found", status: 404)
#
# @example Validation errors
#   ErrorBlueprint.render_as_hash(errors: user.errors, status: 422)
class ErrorBlueprint < BaseBlueprint
  identifier :status

  field :message
  field :errors
  field :timestamp do
    Time.current.iso8601
  end
end
