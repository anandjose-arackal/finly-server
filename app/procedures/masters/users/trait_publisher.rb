# Trait publisher is responsible for publishing user traits to PostHog (Product Analytics) and BulletTrain (FeatureFlags)
class Masters::Users::TraitPublisher

  # Production having very large number of users but not active at the moment
  IGNORE_LIST = [
      1, # Demo Account
      50, # Pro-align
      54 # Jotun India
  ]

  BATCH_SLEEP_DURATION = 2.seconds

  MAILTRAIN_ATTRIBUTES = %w(
    first_name last_name point_of_contact status
    company_id company_name company_group_name company_test_account company_status
  )

  def self.logger
    LogStashLogger.new(type: :file, path: 'log/trait_publisher.log', sync: true)
  end

  def self.enabled?(company_id = nil)
    return false if company_id.present? and IGNORE_LIST.include?(company_id)
    return true if Rails.configuration.bullet_train.present?
    return true if Rails.configuration.posthog.present?

    false
  end

  def self.with_retries(handler, destination, max_retries: 2, sleep: 10, &block)
    attempts = 0
    while attempts < max_retries
      begin
        block.call

        if attempts > 0
          logger.info(
              {handler: handler, destination: destination, action: 'Succeeded after exception'}
          )
        end

        return true
      rescue Exception => e
        logger.info(
            {
                handler: handler, destination: destination, action: 'Exception', exception: ([e.message] + e.backtrace).join("\n")
            }
        )
        sleep sleep
        # Log exception
      end

      attempts += 1
    end

    false
  end

  def logger
    self.class.logger
  end

  def enabled?(company_id = nil)
    self.class.enabled?(company_id)
  end

  def with_retries(handler, destination, max_retries: 2, sleep: 10, &block)
    self.class.with_retries(handler, destination, max_retries: max_retries, sleep: sleep, &block)
  end

  def publish(publisher, user, properties, options: {})
    if Rails.configuration.bullet_train.present? and (options&.dig(:destinations).blank? or options&.dig(:destinations)&.include?('bullet_train'))
      properties.each_pair do |key, value|
        with_retries(publisher, 'bullet_train') do
          Rails.configuration.bullet_train.set_trait user.analytics_id, key, value
        end
      end
    end

    if Rails.configuration.posthog.present? and (options&.dig(:destinations).blank? or options&.dig(:destinations).include?('posthog'))
      with_retries(publisher, 'posthog') do
        Rails.configuration.posthog.identify(
            distinct_id: user.analytics_id,
            properties: properties
        )
      end
    end

    if Rails.configuration.mailtrain.present? and user.email.present? and
        (options&.dig(:destinations).blank? or options&.dig(:destinations).include?('mailtrain'))
      with_retries(publisher, 'mailtrain') do
        request = {email: user.email, timezone: 'Asia/Kolkata', merge_attributes: {}}
        request[:merge_attributes] = properties.slice(*MAILTRAIN_ATTRIBUTES)
        if request[:merge_attributes].present?
          Rails.configuration.mailtrain.client.subscribe(Rails.configuration.mailtrain.customers_list, request)
        end
      end
    end
  end

  # Responsible for refreshing all user traits
  class Masters::Users::TraitPublisher::RefreshUserTraits < Masters::Users::TraitPublisher

    def self.call(timeframe = 10.years.ago, dry_run: false, options: {})
      return unless enabled?

      # Set company specific traits for all users
      Masters::Users::TraitPublisher::CompanyHandler.refresh(timeframe, dry_run: dry_run, options: options)

      # Set user traits for all users
      Masters::Users::TraitPublisher::UserHandler.refresh(timeframe, dry_run: dry_run, options: options)

      # Set role traits for all users
      Masters::Users::TraitPublisher::UserRoleHandler.refresh(timeframe, dry_run: dry_run, options: options)
    end

  end
end