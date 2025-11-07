# frozen_string_literal: true

# Blueprinter configuration
# Customize global settings for API serialization

Blueprinter.configure do |config|
  # Set default date/time format
  config.datetime_format = ->(datetime) { datetime&.iso8601 }

  # Set default field default (value when field is nil)
  # config.field_default = nil

  # Set if blueprint should include root
  # config.root = false

  # Sort fields alphabetically in JSON output
  config.sort_fields_by = :definition
end
