source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.1', '>= 5.2.1.1'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Extra
# UI template
# Replace coffee
gem 'slim-rails', '~> 3.2'

# Database
gem 'pg', '~> 1.1', '>= 1.1.3'

# Serializer
# create serializer eg. rails g serializer Movie name year
# Replace jbuilder
gem 'fast_jsonapi', '~> 1.5'

# Upload file support
# gem 'carrierwave', '~> 1.2', '>= 1.2.2'

# Jquery support
gem 'jquery-rails', '~> 4.3', '>= 4.3.1'
# needed if use jquery3
gem 'jquery-ui-rails', '~> 6.0', '>= 6.0.1'

# Flexible authentication solution for Rails based on Warden
# rails generate devise MODEL
gem 'devise', '~> 4.2'
gem 'devise_token_auth', '~> 1.0'

# Icons
gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'

gem 'sprockets', '~> 3.7', '>= 3.7.2'
# support ES6 with .es6 instead of .es6
gem 'sprockets-es6', '~> 0.9.2'

# authorization
gem 'pundit', '~> 1.1'

# tracking changes
gem 'paper_trail', '~> 10.0', '>= 10.0.1'

# pagination
gem 'pagy', '~> 1.2'

# UI framework
gem 'bootstrap', '~> 4.1', '>= 4.1.3'

# rails assets
source 'https://rails-assets.org' do
  gem 'rails-assets-datetimepicker', '~> 2.5.20'
  gem 'rails-assets-jquery-ui-month-picker', '~> 3.0.4'
end

# Object-based searching
gem 'ransack', '~> 2.1.1'

# generate QR code png
gem 'rqrcode', '~> 0.10.1'

# extract validation from activemodel
gem 'dry-validation', '~> 0.12.2'

# nested form
gem 'cocoon', '~> 1.2', '>= 1.2.12'

# setting
gem "rails-settings-cached"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'awesome_print', '~> 1.8'
  # generates fake data
  gem 'faker', '~> 1.9', '>= 1.9.1'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # ruby lint
  gem 'rubocop', '~> 0.60.0', require: false

  # Better and more useful error page
  gem 'better_errors', '~> 2.5'
  gem 'binding_of_caller', '~> 0.8.0'

  # A static analysis security vulnerability scanner for Ruby on Rails applications
  gem 'brakeman', require: false

  # Preview email in the default browser instead of sending it.
  gem 'letter_opener', '~> 1.6'

  # https://github.com/flyerhzm/bullet
  # increase application's performance by reducing the number of queries it makes
  gem 'bullet', '~> 5.9'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
  # Specify ruby-prof as application's dependency in Gemfile to run benchmarks.
  # gem 'ruby-prof'
  # bring back assigns, assert_template
  gem 'rails-controller-testing', '~> 1.0', '>= 1.0.2'

  gem 'guard', '~> 2.15'
  gem 'guard-minitest', '~> 2.4', '>= 2.4.6'
  gem 'minitest-reporters', '~> 1.3', '>= 1.3.5'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
