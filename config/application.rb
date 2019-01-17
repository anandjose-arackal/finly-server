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

    config.time_zone = 'Kolkata'
    config.active_record.default_timezone = :local

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'aws_details.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end

    Raven.configure do |config|
      config.dsn = 'https://1366119910394a23b856f9e8334d19ff:8e87d42818e842c189cac4dedb735ace@sentry.finly.io/2'
    end

    # config.autoload_paths += %W(#{config.root}/lib)

    config.eager_load_paths << Rails.root.join('lib')

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
