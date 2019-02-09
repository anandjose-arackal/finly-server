Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  # config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.serve_static_files = true
  # config.serve_static_assets = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true
  # config.assets.precompile =  ['*.js', '*.css', '*.css.erb']


  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # config.logstasher.enabled = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  config.lograge.enabled = true
  # config.lograge.keep_original_rails_log = true
  config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/logstash_#{Rails.env}.log"
  config.lograge.formatter = Lograge::Formatters::Logstash.new
  config.lograge.custom_options = lambda do |event|
    {
        exception: event.payload[:exception], # ["ExceptionClass", "the message"]
        exception_object: event.payload[:exception_object] # the exception instance
    }
  end

  config.lograge.custom_payload do |controller|
    user = controller.current_user
    hash = {params: RequestStore.store[:request_params]}
    hash[:current_app] = (controller.current_app rescue nil)
    hash[:current_device] = (controller.current_device rescue nil)
    if user.present?
      hash[:user_id] = user&.id
      hash[:user_name] = (user&.name rescue nil)
      hash[:user_email] = user&.email
      hash[:user_mobile_number] = user&.mobile_number
      hash[:company_name] = (controller.current_company&.name rescue nil)
      hash[:company_id] = (controller.current_company&.id rescue nil)
      hash[:current_view] = (controller.params&.dig(:view) rescue nil)
    end
    hash.as_json
  end

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  ################### SETTINGS FOR SENDGRID ##########################
  config.action_mailer.default_url_options = { host: 'staging.finly.io' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address:              'smtp.sendgrid.net',
      port:                 587,
      domain:               'staging.finly.io',
      user_name:            'vivekagb',
      password:             'idAr5APhk61X',
      # ssl:                  true,
      # tls:                  true,
      authentication:       :plain,
      enable_starttls_auto: true,
      :openssl_verify_mode  => 'none'
  }

  #####################################################################

  # # temporary config for mailers
  # config.action_mailer.raise_delivery_errors = true
  # config.action_mailer.delivery_method = :test
  # config.action_mailer.default_url_options = { host: 'localhost:3000'}

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  ###################### SETTINGS FOR USING S3 FOR ALL ATTACHMENTS ########################
  config.paperclip_defaults = {
      storage: :s3,
      s3_region: config.aws_config["aws_region_name"],
      s3_credentials: {
          s3_host_name: config.aws_config["s3_host_name"],
          bucket: config.aws_config["s3_attachment_bucket_name"],
          s3_region: config.aws_config["aws_region_name"],
          access_key_id: config.aws_config["aws_access_key_id"],
          secret_access_key: config.aws_config["aws_secret_access_key"]
      },
      :s3_protocol => :https,
      :s3_headers => {
          :content_disposition => 'attachment'
      }
  }
  #########################################################################################

end
