# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'sprockets/es6'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AttendanceWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.autoload_paths += %W[#{config.root}/lib] # add this line
    config.eager_load_paths += %W[#{config.root}/lib]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.api_only = false
    config.middleware.use ActionDispatch::Flash
    config.time_zone = 'Kuala Lumpur'
    VERSION = '0.0.1 BETA'
  end
end
