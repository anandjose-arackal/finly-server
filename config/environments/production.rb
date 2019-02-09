Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # config.logstasher.enabled = true
  # config.logstasher.field_renaming = {
  #     error: :exception,
  # }

  # Raven.configure do |config|
  #   # config.dsn = "https://1366119910394a23b856f9e8334d19ff:8e87d42818e842c189cac4dedb735ace@sentry.finly.io/2"
  #   config.dsn = YAML.load_file(Rails.root.join('config/sentry.yml'))['dsn']
  # end

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
    hash = {params: RequestStore.store[:request_params]&.except(:password, :password_confirmation)}
    hash[:current_app] = (controller.current_app rescue nil)
    hash[:current_device] = (controller.current_device rescue nil)
    hash[:ip] = controller.request.ip
    hash[:request_id] = controller.request.request_id
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

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # todo Commented during migration to Rails 5
  # config.serve_static_files = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "finly_#{Rails.env}"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  ################### SETTINGS FOR EMAIL ##########################
  config.mailer_config = config_for(:mailer_config)
  config.action_mailer.default_url_options = {host: config.mailer_config['email_host']}
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address: config.mailer_config['email_address'],
      port: config.mailer_config['email_port'],
      domain: config.mailer_config['email_domain'],
      user_name: config.mailer_config['email_user_name'],
      password: config.mailer_config['email_password'],
      # ssl:                  true,
      # tls:                  true,
      authentication: :plain,
      enable_starttls_auto: true,
      :openssl_verify_mode => 'none'
  }

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.aws_config = config_for(:aws_config)
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
