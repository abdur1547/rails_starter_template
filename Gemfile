# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.4.1"

gem "rails", "~> 8.0.2"

gem "sprockets-rails"

gem "pg", "~> 1.6"

gem "puma", ">= 5.0"

gem "figaro"

gem "importmap-rails"

gem "haml", "~> 6.3"

# dry-rb gems
gem "dry-matcher", "~> 1.0"
gem "dry-monads", "~> 1.9"
gem "dry-validation", "~> 1.11"

# for JSON responce
gem "blueprinter", "~> 1.1.2"
gem "oj"

gem "turbo-rails"

gem "stimulus-rails"

# for file storage
gem "shrine", "~> 3.6"

gem "sidekiq", "~> 8.0"

gem "redis", ">= 4.0.1"
# gem "kredis"

gem "rack-cors"

gem "pagy", "~> 9.4"

gem "devise", "~> 4.9"
gem "jwt", "~> 2.10"
gem "omniauth", "~> 2.1"
gem "omniauth-google-oauth2", "~> 1.2"
gem "omniauth-rails_csrf_protection", "~> 1.0", ">= 1.0.2"

gem "tzinfo-data"

gem "bootsnap", require: false

# gem "image_processing", "~> 1.2"

# http requests
gem "httparty", "~> 0.23.1"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "factory_bot_rails", "~> 6.5"
  gem "faker", "~> 3.5"
  gem "json_matchers", "~> 0.11.1"
  gem "rspec-rails", "~> 8.0"
  gem "simplecov", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "html2haml"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rails-omakase"
  gem "web-console"
end
