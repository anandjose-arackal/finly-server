module Masters
  module Users
    # Trait publisher is responsible for publishing user traits to PostHog (Product Analytics) and BulletTrain (FeatureFlags)
    module TraitPublisher

      # Production having very large number of users but not active at the moment
      IGNORE_LIST = [
          1, # Demo Account
          50, # Pro-align
          54 # Jotun India
      ]

      def self.logger
        LogStashLogger.new(type: :file, path: 'log/trait_publisher.log', sync: true)
      end

      def self.with_retries(handler, destination, max_retries: 2, sleep: 10, &block)
        attempts = 0
        while attempts < max_retries
          begin
            block.call

            if attempts > 0
              Masters::Users::TraitPublisher.logger.info(
                  {handler: handler, destination: destination, action: 'Succeeded after exception'}
              )
            end

            return true
          rescue Exception => e
            Masters::Users::TraitPublisher.logger.info(
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

      # Responsible for publishing company properties
      class CompanyHandler
        # include Events::Consumer

        # consumes_event! 'companies.*'

        def self.refresh(changed_since, dry_run: false)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          companies = Company.where('updated_at > ?', changed_since)
          companies = companies.limit(2) if dry_run
          start_time = Time.now
          companies.includes(:status, :group).all.each do |c|
            new.work(nil, {record: c, dry_run: dry_run})
          end
          Masters::Users::TraitPublisher.logger.info(
              {handler: self.name, action: 'Refresh Completed', changed_since: changed_since, started_at: start_time,
               ended_at: Time.now, total_time: (Time.now - start_time).to_f,
               records_updated: companies.count, total_records: companies.count}
          )
        end

        def work(u, payload)
          company = payload[:record]
          return if IGNORE_LIST.include?(company.id)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          users = company.users.where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
          users = users.limit(100) if payload[:dry_run]
          total_users = company.users.count
          completed_users = 0
          start_time = Time.now

          users.find_in_batches(batch_size: 1000) do |batch|
            batch_start = Time.now
            batch.each do |user|
              properties = {
                  'company_id' => company.id,
                  "company_name" => company.name,
                  "company_active" => !!company.active,
                  "company_subdomain" => company.subdomain,
                  "company_test_account" => !!company.test_account,
                  "company_group_name" => company.group&.name,
                  "company_status" => company.status&.name,
                  'company_deleted_at' => company.deleted_at,
              }.compact

              if Rails.configuration.bullet_train.present?
                properties.each_pair do |key, value|
                  Masters::Users::TraitPublisher.with_retries(self.class.name, 'bullet_train') do
                    Rails.configuration.bullet_train.set_trait user.analytics_id, key, value
                  end
                end
              end
              if Rails.configuration.posthog.present?
                Masters::Users::TraitPublisher.with_retries(self.class.name, 'posthog') do
                  Rails.configuration.posthog.identify(
                      distinct_id: user.analytics_id,
                      properties: properties
                  )
                end
              end

              true
            end
            completed_users += batch.size
            Masters::Users::TraitPublisher.logger.info(
                {
                    handler: self.class.name, action: 'Batch Updated', started_at: batch_start,
                    ended_at: Time.now, total_time: (Time.now - batch_start).to_f, records_updated: batch.size,
                    total_records: total_users, company_name: company.name, company_id: company.id,
                }
            )

            sleep 2
          end

          Masters::Users::TraitPublisher.logger.info(
              {
                  handler: self.class.name, action: 'Job Completed', started_at: start_time,
                  ended_at: Time.now, total_time: (Time.now - start_time).to_f, records_updated: total_users,
                  total_records: total_users, company_name: company.name, company_id: company.id,
              }
          )
        end
      end

      # Updates the user and user profile attributes by using the +users.create+ and +users.update+ hooks.
      class UserHandler
        # include Events::Consumer

        # consumes_event! 'users.*'

        def self.refresh(changed_since, dry_run: false)
          return if changed_since.nil?
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          users = User.where('updated_at > ?', changed_since)
                      .where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
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
            Masters::Users::TraitPublisher.logger.info(
                {
                    handler: self.name, action: 'Batch Updated', started_at: batch_start_time,
                    ended_at: Time.now, total_time: (Time.now - batch_start_time).to_f, records_updated: completed_users,
                    total_records: total_users, batch_size: batch.size
                }
            )
            sleep 2
          end

          Masters::Users::TraitPublisher.logger.info(
              {
                  handler: self.name, action: 'Refresh Completed', started_at: start_time,
                  ended_at: Time.now, total_time: (Time.now - start_time).to_f, records_updated: completed_users,
                  total_records: total_users
              }
          )
        end

        def work(user, payload)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          user = payload[:record]
          return if Masters::Users::TraitPublisher::IGNORE_LIST.include?(user.company_id)

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

          if Rails.configuration.bullet_train.present?
            properties.each_pair do |key, value|
              Masters::Users::TraitPublisher.with_retries(self.class.name, 'bullet_train') do
                Rails.configuration.bullet_train.set_trait user.analytics_id, key, value
              end
            end
          end
          if Rails.configuration.posthog.present?
            Masters::Users::TraitPublisher.with_retries(self.class.name, 'posthog') do
              Rails.configuration.posthog.identify(
                  distinct_id: user.analytics_id,
                  properties: properties
              )
            end
          end
          true
        end
      end

      # For capturing user permissions and roles
      class UserRoleHandler
        # include Events::Consumer

        # consumes_event! 'user_role_mappings.*', 'policy_user_roles.*'

        def self.refresh(changed_since, dry_run: false)
          return if changed_since.nil?
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          role_mappings = UserRoleMapping.unscoped.where('user_role_mappings.updated_at > ?', changed_since)
                              .joins(:user)
                              .where.not(users: {company_id: Masters::Users::TraitPublisher::IGNORE_LIST})
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
            Masters::Users::TraitPublisher.logger.info(
                {
                    handler: "#{self.name}#UserRoleMappings", action: 'Batch Updated', started_at: batch_start_time,
                    ended_at: Time.now, total_time: (Time.now - batch_start_time).to_f, records_updated: completed_records,
                    total_records: total_records, batch_size: batch.size
                }
            )
            sleep 2
          end

          Masters::Users::TraitPublisher.logger.info(
              {
                  handler: "#{self.name}#UserRoleMappings", action: 'Refresh Completed', started_at: start_time,
                  ended_at: Time.now, total_time: (Time.now - start_time).to_f, records_updated: completed_records,
                  total_records: total_records
              }
          )

          role_mappings = PolicyUserRole.unscoped.where('policy_user_roles.updated_at > ?', changed_since)
                              .joins(:user)
                              .where.not(users: {company_id: Masters::Users::TraitPublisher::IGNORE_LIST})
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
            Masters::Users::TraitPublisher.logger.info(
                {
                    handler: "#{self.name}#PolicyUserRoleMappings", action: 'Batch Updated', started_at: batch_start_time,
                    ended_at: Time.now, total_time: (Time.now - batch_start_time).to_f, records_updated: completed_records,
                    total_records: total_records, batch_size: batch.size
                }
            )
            sleep 2
          end

          Masters::Users::TraitPublisher.logger.info(
              {
                  handler: "#{self.name}#PolicyUserRoleMappings", action: 'Refresh Completed', started_at: start_time,
                  ended_at: Time.now, total_time: (Time.now - start_time).to_f, records_updated: completed_records,
                  total_records: total_records
              }
          )
        end

        def work(user, payload)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          role_mapping = payload[:record]
          return if IGNORE_LIST.include?(role_mapping.user.company_id)
          return if role_mapping.user_role&.name.blank?

          # Role is assigned to the user if the deleted_at flag is not set
          assigned = role_mapping.deleted_at.nil?
          Masters::Users::TraitPublisher.with_retries(self.class.name, 'bullet_train') do
            Rails.configuration.bullet_train&.set_trait role_mapping.user.analytics_id, "permission_#{role_mapping.user_role.name}", assigned
          end
          Masters::Users::TraitPublisher.with_retries(self.class.name, 'posthog') do
            Rails.configuration.posthog&.identify(
                distinct_id: role_mapping.user.analytics_id,
                properties: {
                    "permission_#{role_mapping.user_role.name}" => assigned
                }
            )
          end
        end
      end

      # Tracks user sessions in bullet train
      # class UserSessionTracker
      #   # include Events::Consumer
      #
      #   # consumes_event! 'user_sessions.create'
      #
      #   def self.refresh(changed_since)
      #     return if changed_since.nil?
      #     return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?
      #
      #     User.where('updated_at > ?', changed_since)
      #         .where(company_id: 2)
      #         .where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
      #         .find_in_batches do |batch|
      #       UserSession.where(user_id: batch.pluck(:id)).group(:user_id).count.each do |user_id, count|
      #         Rails.configuration.bullet_train&.set_trait "user:#{user_id}", 'user_sessions', count
      #       end
      #       sleep 10
      #     end
      #   end
      #
      #   def work(user, payload)
      #     user_session = payload[:record]
      #     return if user_session.blank?
      #     return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?
      #
      #     Rails.configuration.bullet_train&.incr_counter user.analytics_id, 'user_sessions'
      #   end
      # end

      # Responsible for refreshing all user traits
      class RefreshUserTraits

        def self.call(timeframe = 10.years.ago, dry_run: false)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          # Set company specific traits for all users
          Masters::Users::TraitPublisher::CompanyHandler.refresh(timeframe, dry_run: dry_run)

          # Set user traits for all users
          Masters::Users::TraitPublisher::UserHandler.refresh(timeframe, dry_run: dry_run)

          # Set role traits for all users
          Masters::Users::TraitPublisher::UserRoleHandler.refresh(timeframe, dry_run: dry_run)

          # Track user logins / sessions
          # Masters::Users::TraitPublisher::UserSessionTracker.refresh(timeframe)
        end

      end
    end
  end
end