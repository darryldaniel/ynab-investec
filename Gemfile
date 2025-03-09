source "https://rubygems.org"

ruby "3.3.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use mysql as the database for Active Record
gem "trilogy", "~> 2.8"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
    # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
    gem "debug", platforms: %i[ mri windows ]
    gem "dotenv-rails", "~> 2.8"
    gem "factory_bot_rails"
end

group :development do
    # Use console on exceptions pages [https://github.com/rails/web-console]
    gem "web-console"

    # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
    # gem "rack-mini-profiler"

    # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
    # gem "spring"

    gem "pry-rails"
end

group :test do
    # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
    gem "capybara"
    gem "selenium-webdriver"
    gem "faker", "~> 3.2"
    gem "minitest-spec-rails"
    gem "mocha"
    gem "simplecov", require: false
end

gem "ynab", "~> 2.1"

gem "faraday", "~> 2.7"

gem "whenever", "~> 1.0", require: false

gem "cronitor", "~> 5.1.0"

gem "investec_open_api", git: "https://github.com/Investec-Developer-Community/investec_open_api", ref: "0196a5"

gem "money-rails", "~> 1.15"

gem "lograge"

gem "solid_queue", "~> 1.1.0"
