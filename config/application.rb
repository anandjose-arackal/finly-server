require_relative 'boot'

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Finly
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    config.trailblazer.enable_loader = false
    config.time_zone = 'Kolkata'
    config.active_record.default_timezone = :local
    config.middleware.use Rack::Attack

    # config.autoload_paths += %W(#{config.root}/lib)

    config.eager_load_paths << Rails.root.join('lib')

    Raven.configure do |config|
      config.dsn = 'https://bed720c1d80849fcbc96fba0485460e6@sentry.finly.io/2'
    end

    config.filter_parameters << :password

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
