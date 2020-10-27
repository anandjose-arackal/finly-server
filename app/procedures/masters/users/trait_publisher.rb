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
    user_id first_name last_name point_of_contact status
    company_id company_name company_group_name company_test_account company_status
    product_em product_vp role_em_admin role_vp_admin module_i2p module_p2p module_abp module_budgets module_payments
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
      # Masters::Users::TraitPublisher::CompanyHandler.refresh(timeframe, dry_run: dry_run, options: options)
      #
      # # Set user traits for all users
      # Masters::Users::TraitPublisher::UserHandler.refresh(timeframe, dry_run: dry_run, options: options)
      companies = Company.where('updated_at > ?', timeframe).select(:id).to_sql
      feature_subscriptions = FeatureSubscription.where('updated_at > ?', timeframe).select(:subscribable_id).to_sql
      user_subscriptions = UserPanelSubscription.where('updated_at > ?', timeframe).select(:user_id).to_sql
      users = User.all.where('updated_at > ?', timeframe)
                  .or(User.where("company_id in (#{companies})"))
                  .or(User.where("company_id in (#{feature_subscriptions})"))
                  .or(User.where("id in (#{user_subscriptions})"))
      users = users.where.not(company_id: IGNORE_LIST)
      users = users.limit(10) if dry_run
      total_users = users.count
      completed_users = 0
      users = users.includes(
          :company, {company: [:feature_subscription, :status, :group]},
          :user_panel_subscription, :policy_user_roles, :role_mapping,
      )
      instance = self.new
      start_time = Time.now
      users.find_in_batches(batch_size: 1000) do |batch|
        batch_start_time = Time.now
        batch.each do |user|
          next unless enabled?(user.company_id)
          properties = Masters::Users::TraitPublishers::CompanyHandler.properties(user.company)
                           .merge(Masters::Users::TraitPublishers::FeatureSubscriptionHandler.properties(user))
                           .merge(Masters::Users::TraitPublishers::UserHandler.properties(user))
          instance.publish(self.class, user, properties, options: options)
        end
        completed_users += batch.size
        logger.info(
            {
                handler: self.name, action: 'Batch Updated', started_at: batch_start_time,
                ended_at: Time.now, total_time: (Time.now - batch_start_time).to_f, records_updated: completed_users,
                total_records: total_users, batch_size: batch.size
            }
        )
        sleep BATCH_SLEEP_DURATION
      end

      logger.info(
          {
              handler: self.name, action: 'Refresh Completed', started_at: start_time,
              ended_at: Time.now, total_time: (Time.now - start_time).to_f, records_updated: completed_users,
              total_records: total_users
          }
      )

      # Set role traits for all users
      Masters::Users::TraitPublisher::UserRoleHandler.refresh(timeframe, dry_run: dry_run, options: options)
    end

  end
end