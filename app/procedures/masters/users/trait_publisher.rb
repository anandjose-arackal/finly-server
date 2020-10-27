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

  # Responsible for publishing company properties
  class Masters::Users::TraitPublisher::CompanyHandler < Masters::Users::TraitPublisher

    def self.refresh(changed_since, dry_run: false, options: {})
      return unless enabled?

      companies = Company.where('updated_at > ?', changed_since)
      companies = companies.limit(2) if dry_run
      start_time = Time.now
      companies.includes(:status, :group).all.each do |c|
        new.work(nil, {record: c, dry_run: dry_run, options: options})
      end
      logger.info(
          {handler: self.name, action: 'Refresh Completed', changed_since: changed_since, started_at: start_time,
           ended_at: Time.now, total_time: (Time.now - start_time).to_f,
           records_updated: companies.count, total_records: companies.count}
      )
    end

    def work(u, payload)
      company = payload[:record]
      return false unless enabled?(company.id)

      users = company.users.where.not(company_id: IGNORE_LIST)
      users = users.limit(100) if payload[:dry_run]
      total_users = company.users.count
      completed_users = 0
      start_time = Time.now

      users.find_in_batches(batch_size: 1000) do |batch|
        batch_start = Time.now
        batch.each do |user|
          properties = {
              'company_id' => company.id,
              'company_name' => company.name,
              'company_active' => !!company.active,
              'company_subdomain' => company.subdomain,
              'company_test_account' => !!company.test_account,
              'company_group_name' => company.group&.name,
              'company_status' => company.status&.name,
              'company_deleted_at' => company.deleted_at,
          }.compact

          publish(self.class, user, properties, options: payload[:options])
        end
        completed_users += batch.size
        logger.info(
            {
                handler: self.class.name, action: 'Batch Updated', started_at: batch_start,
                ended_at: Time.now, total_time: (Time.now - batch_start).to_f, records_updated: batch.size,
                total_records: total_users, company_name: company.name, company_id: company.id,
            }
        )

        sleep BATCH_SLEEP_DURATION
      end

      logger.info(
          {
              handler: self.class.name, action: 'Job Completed', started_at: start_time,
              ended_at: Time.now, total_time: (Time.now - start_time).to_f, records_updated: total_users,
              total_records: total_users, company_name: company.name, company_id: company.id,
          }
      )
    end
  end

  # Updates the user and user profile attributes by using the +users.create+ and +users.update+ hooks.
  class Masters::Users::TraitPublisher::UserHandler < Masters::Users::TraitPublisher

    def self.refresh(changed_since, dry_run: false, options: {})
      return if changed_since.nil?
      return unless enabled?

      users = User.where('updated_at > ?', changed_since)
                  .where.not(company_id: IGNORE_LIST)
      users = users.limit(100) if dry_run
      total_users = users.count
      start_time = Time.now
      completed_users = 0
      users.find_in_batches(batch_size: 1000) do |batch|
        batch_start_time = Time.now
        batch.each do |user|
          self.new.work(nil, record: user)
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
    end

    def work(user, payload)
      user = payload[:record]
      return unless enabled?(user.company_id)

      properties = {
          'email' => user.email,
          'mobile_number' => user.mobile_number,
          'first_name' => user.first_name,
          'last_name' => user.last_name,
          'deleted_at' => user.deleted_at,
          'verified' => !!user.verified,
          'has_set_password' => !!user.default_password,
          'point_of_contact' => !!user.point_of_contact,
          'otp_verified' => !!user.otp_verified,
          'status' => user.status
      }.compact

      publish(self.class, user, properties, options: payload[:options])
      true
    end
  end

  # For capturing user permissions and roles
  class Masters::Users::TraitPublisher::UserRoleHandler < Masters::Users::TraitPublisher
    # include Events::Consumer

    # consumes_event! 'user_role_mappings.*', 'policy_user_roles.*'

    def self.refresh(changed_since, dry_run: false, options: {})
      return if changed_since.nil?
      return unless enabled?

      role_mappings = UserRoleMapping.unscoped.where('user_role_mappings.updated_at > ?', changed_since)
                          .joins(:user)
                          .where.not(users: {company_id: IGNORE_LIST})
      role_mappings = role_mappings.limit(100) if dry_run

      total_records = role_mappings.count
      start_time = Time.now
      completed_records = 0
      role_mappings.includes(:user, :user_role)
          .joins(:user)
          .find_in_batches(batch_size: 1000) do |batch|
        batch_start_time = Time.now
        batch.each do |role_mapping|
          self.new.work(nil, record: role_mapping)
        end
        completed_records += batch.size
        logger.info(
            {
                handler: "#{self.name}#UserRoleMappings", action: 'Batch Updated', started_at: batch_start_time,
                ended_at: Time.now, total_time: (Time.now - batch_start_time).to_f, records_updated: completed_records,
                total_records: total_records, batch_size: batch.size
            }
        )
        sleep BATCH_SLEEP_DURATION
      end

      logger.info(
          {
              handler: "#{self.name}#UserRoleMappings", action: 'Refresh Completed', started_at: start_time,
              ended_at: Time.now, total_time: (Time.now - start_time).to_f, records_updated: completed_records,
              total_records: total_records
          }
      )

      role_mappings = PolicyUserRole.unscoped.where('policy_user_roles.updated_at > ?', changed_since)
                          .joins(:user)
                          .where.not(users: {company_id: IGNORE_LIST})
      role_mappings = role_mappings.limit(100) if dry_run
      total_records = role_mappings.count
      start_time = Time.now
      completed_records = 0
      role_mappings.includes(:user, :user_role)
          .joins(:user)
          .find_in_batches(batch_size: 1000) do |batch|
        batch_start_time = Time.now
        batch.each do |role_mapping|
          self.new.work(nil, record: role_mapping)
        end
        completed_records += batch.size
        logger.info(
            {
                handler: "#{self.name}#PolicyUserRoleMappings", action: 'Batch Updated', started_at: batch_start_time,
                ended_at: Time.now, total_time: (Time.now - batch_start_time).to_f, records_updated: completed_records,
                total_records: total_records, batch_size: batch.size
            }
        )
        sleep BATCH_SLEEP_DURATION
      end

      logger.info(
          {
              handler: "#{self.name}#PolicyUserRoleMappings", action: 'Refresh Completed', started_at: start_time,
              ended_at: Time.now, total_time: (Time.now - start_time).to_f, records_updated: completed_records,
              total_records: total_records
          }
      )
    end

    def work(user, payload)

      role_mapping = payload[:record]
      return if role_mapping.user_role&.name.blank?
      return unless enabled?(role_mapping.user.company_id)

      # Role is assigned to the user if the deleted_at flag is not set
      assigned = role_mapping.deleted_at.nil?
      properties = {:"permission_#{role_mapping.user_role.name}" => assigned}
      publish(self.class, role_mapping.user, properties, options: payload[:options])
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
end