source "https://rubygems.org"

gem "rails", "~> 8.1.1"

# DB
gem "pg", "~> 1.1"

# Web server
gem "puma", ">= 5.0"

# Assets
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# JSON
gem "blueprinter"

# CORS support
gem "rack-cors", "~> 3.0"

# HAML
gem "haml", "~> 6.3"
gem "haml-rails", "~> 2.1"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Dry gems for operations pattern
gem "dry-validation", "~> 1.10"
gem "dry-monads", "~> 1.6"

# Simple, Heroku-friendly Rails app configuration using ENV and a single YAML file
gem "figaro"

# Authentication
gem "devise", "~> 4.9"
gem "devise-jwt", "~> 0.11"
gem "omniauth-google-oauth2", "~> 1.1"
gem "omniauth-rails_csrf_protection"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # RSpec testing framework
  gem "rspec-rails", "~> 7.1"

  # Factory Bot for test fixtures
  gem "factory_bot_rails", "~> 6.4"

  # Generate fake data for testing
  gem "faker", "~> 3.5"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Convert HTML/ERB to HAML
  gem "html2haml"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  # RSpec matchers for common Rails functionality
  gem "shoulda-matchers", "~> 6.4"

  # Database cleaner for test isolation
  gem "database_cleaner-active_record", "~> 2.2"

  # Code coverage analysis
  gem "simplecov", "~> 0.22", require: false
end
