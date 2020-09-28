Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  feature_flipper_config = Rails.application.config_for(:feature_flipper)
  if feature_flipper_config.dig('api_key').present? and feature_flipper_config.dig('url').present?
    config.bullet_train = BulletTrain.new(api_key: feature_flipper_config['api_key'], url: feature_flipper_config['url'])
  else
    config.bullet_train = nil
  end

  posthog_config = Rails.application.config_for(:posthog)
  config.posthog = PostHog::Client.new(
      {
          api_key: posthog_config['api_key'],
          api_host: posthog_config['api_host'],
          on_error: Proc.new { |status, msg| print msg }
      }
  )

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # config.lograge.enabled = true
  # # config.lograge.keep_original_rails_log = true
  # config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/logstash_#{Rails.env}.log"
  # config.lograge.formatter = Lograge::Formatters::Logstash.new
  # config.lograge.custom_options = lambda do |event|
  #   {
  #       exception: event.payload[:exception], # ["ExceptionClass", "the message"]
  #       exception_object: event.payload[:exception_object] # the exception instance
  #   }
  # end
  #
  # config.lograge.custom_payload do |controller|
  #   user = controller.current_user
  #   params = RequestStore.store[:request_params]&.except(:password, :password_confirmation)
  #   params = LogSanitizer.sanitize params if params.present?
  #   hash = {params: params}
  #   hash[:current_app] = (controller.current_app rescue nil)
  #   hash[:current_device] = (controller.current_device rescue nil)
  #   hash[:ip] = controller.request.remote_ip
  #   hash[:request_id] = controller.request.request_id
  #   if user.present?
  #     hash[:user_id] = user&.id
  #     hash[:user_name] = (user&.name rescue nil)
  #     hash[:user_email] = user&.email
  #     hash[:user_mobile_number] = user&.mobile_number
  #     hash[:company_name] = (controller.current_company&.name rescue nil)
  #     hash[:company_id] = (controller.current_company&.id rescue nil)
  #     hash[:current_view] = (controller.params&.dig(:view) rescue nil)
  #   end
  #   hash.as_json
  # end

  config.serve_static_files = true

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # config.lograge.enabled = true
  # # config.lograge.keep_original_rails_log = true
  # config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/logstash_#{Rails.env}.log"
  # config.lograge.formatter = Lograge::Formatters::Logstash.new
  # config.lograge.custom_options = lambda do |event|
  #   {
  #       exception: event.payload[:exception], # ["ExceptionClass", "the message"]
  #       exception_object: event.payload[:exception_object] # the exception instance
  #   }
  # end
  #
  # config.lograge.custom_payload do |controller|
  #   user = controller.current_user
  #   hash = {params: RequestStore.store[:request_params]}
  #   hash[:current_app] = (controller.current_app rescue nil)
  #   hash[:current_device] = (controller.current_device rescue nil)
  #   if user.present?
  #     hash[:user_id] = user&.id
  #     hash[:user_name] = (user&.name rescue nil)
  #     hash[:user_email] = user&.email
  #     hash[:user_mobile_number] = user&.mobile_number
  #     hash[:company_name] = (controller.current_company&.name rescue nil)
  #     hash[:company_id] = (controller.current_company&.id rescue nil)
  #     hash[:current_view] = (controller.params&.dig(:view) rescue nil)
  #   end
  #   hash.as_json
  # end

  config.mailer_config = config_for(:mailer_config)
  config.action_mailer.deliver_later_queue_name = 'mailer_queue'
  config.action_mailer.default_url_options = {host: config.mailer_config['host']}
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {address: "localhost", port: 1025}
  # config.action_mailer.smtp_settings = {
  #     address: config.mailer_config['address'],
  #     port: config.mailer_config['port'],
  #     domain: config.mailer_config['domain'],
  #     user_name: config.mailer_config['username'],
  #     password: config.mailer_config['password'],
  #     # ssl:                  true,
  #     # tls:                  true,
  #     authentication: :plain,
  #     enable_starttls_auto: true,
  #     :openssl_verify_mode => 'none'
  # }

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
  end

  ###################### S3 for local attachments ########################
  # config.aws_config = config_for(:aws_config)
  # config.paperclip_defaults = {
  #     storage: :s3,
  #     s3_region: config.aws_config["aws_region_name"],
  #     s3_credentials: {
  #         s3_host_name: config.aws_config["s3_host_name"],
  #         bucket: config.aws_config["s3_attachment_bucket_name"],
  #         s3_region: config.aws_config["aws_region_name"],
  #         access_key_id: config.aws_config["aws_access_key_id"],
  #         secret_access_key: config.aws_config["aws_secret_access_key"]
  #     },
  #     :s3_protocol => :https,
  #     :s3_headers => {
  #         :content_disposition => 'attachment'
  #     }
  # }
  #########################################################################################

  # Azure credentials for blob storage
  # Paperclip::Attachment.default_options[:storage] = :azure
  # Paperclip::Attachment.default_options[:azure_credentials] = {
  #     storage_account_name: "finlyimagestest",
  #     storage_access_key:   "2YzD7rkwZ4+ZRhhnN0cC0QOPZwpPfsx8kaqU3QzkkHa69x5smapm+aL9mDWl/kpuZIu76pMHwDBlAJh0vMl/Ow==",
  #     container:            "finly-images-test"
  # }

  # config.azure_config = config_for(:azure_config)
  # ##################### SETTINGS FOR AZURE BLOB STORAGE ##################################
  # Paperclip::Attachment.default_options[:storage] = :azure
  # Paperclip::Attachment.default_options[:azure_credentials] = {
  #     storage_account_name: config.azure_config["storage_account_name"],
  #     storage_access_key:   config.azure_config["storage_access_key"],
  #     container:            config.azure_config["container"]
  # }
  ####################### SETTINGS FOR AZURE BLOB STORAGE #################################

end
