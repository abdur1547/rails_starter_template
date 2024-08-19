# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.4'

gem 'rails', '~> 7.2.0'

gem 'sprockets-rails'

gem 'pg', '~> 1.5'

gem 'puma', '>= 5.0'

gem 'figaro'

gem 'importmap-rails'

gem 'haml', '~> 6.3'

# dry-rb gems
gem 'dry-matcher', '~> 1.0'
gem 'dry-monads', '~> 1.6'
gem 'dry-validation', '~> 1.10'

# for JSON responce
gem 'blueprinter', '~> 1.1.0'
gem 'oj'

gem 'turbo-rails'

gem 'stimulus-rails'

# for file storage
gem 'shrine', '~> 3.6'

gem 'sidekiq', '~> 7.3'

gem 'redis', '>= 4.0.1'
# gem "kredis"

gem 'rack-cors'

gem 'devise', '~> 4.9'
gem 'jwt', '~> 2.8', '>= 2.8.2'
gem 'omniauth', '~> 2.1', '>= 2.1.2'
gem 'omniauth-google-oauth2', '~> 1.1', '>= 1.1.2'
gem 'omniauth-rails_csrf_protection', '~> 1.0', '>= 1.0.2'

gem 'tzinfo-data'

gem 'bootsnap', require: false

# gem "image_processing", "~> 1.2"

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.4'
  gem 'json_matchers', '~> 0.11.1'
  gem 'rspec-rails', '~> 6.1'
end

group :development do
  gem 'html2haml'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'solargraph', require: false
  gem 'web-console'
end
