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

      # Responsible for publishing company properties
      class CompanyHandler
        # include Events::Consumer

        # consumes_event! 'companies.*'

        def self.refresh(changed_since)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          Company.where('updated_at > ?', changed_since).all.each do |c|
            new.work(nil, record: c)
          end
        end

        def work(current_user, payload)
          company = payload[:record]
          return if IGNORE_LIST.include?(company.id)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          company.users.where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST).find_each do |user|
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
                Rails.configuration.bullet_train.set_trait user.analytics_id, key, value
              end
            end
            if Rails.configuration.posthog.present?
              Rails.configuration.posthog.identify(
                  distinct_id: user.analytics_id,
                  properties: properties
              )
            end

            true
          end
        end
      end

      # Updates the user and user profile attributes by using the +users.create+ and +users.update+ hooks.
      class UserHandler
        # include Events::Consumer

        # consumes_event! 'users.*'

        def self.refresh(changed_since)
          return if changed_since.nil?
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          User.where('updated_at > ?', changed_since)
              .where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
              .find_each do |user|
            self.new.work(nil, record: user)
          end
        end

        def work(current_user, payload)
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
              Rails.configuration.bullet_train.set_trait user.analytics_id, key, value
            end
          end
          if Rails.configuration.posthog.present?
            Rails.configuration.posthog.identify(
                distinct_id: user.analytics_id,
                properties: properties
            )
          end
          true
        end
      end

      # For capturing user permissions and roles
      class UserRoleHandler
        # include Events::Consumer

        # consumes_event! 'user_role_mappings.*', 'policy_user_roles.*'

        def self.refresh(changed_since)
          return if changed_since.nil?
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          UserRoleMapping.unscoped.where('user_role_mappings.updated_at > ?', changed_since)
              .includes(:user, :user_role)
              .joins(:user)
              .where.not(users: {company_id: Masters::Users::TraitPublisher::IGNORE_LIST})
              .find_each do |role_mapping|
            self.new.work(nil, record: role_mapping)
          end

          PolicyUserRole.unscoped.where('policy_user_roles.updated_at > ?', changed_since)
              .includes(:user, :user_role)
              .joins(:user)
              .where.not(users: {company_id: Masters::Users::TraitPublisher::IGNORE_LIST})
              .find_each do |role_mapping|
            self.new.work(nil, record: role_mapping)
          end
        end

        def work(current_user, payload)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          role_mapping = payload[:record]
          return if IGNORE_LIST.include?(role_mapping.user.company_id)
          return if role_mapping.user_role&.name.blank?

          # Role is assigned to the user if the deleted_at flag is not set
          assigned = role_mapping.deleted_at.nil?
          Rails.configuration.bullet_train&.set_trait user.analytics_id, "permission_#{role_mapping.user_role.name}", assigned
          Rails.configuration.posthog&.identify(
              distinct_id: user.analytics_id,
              properties: {
                  "permission_#{role_mapping.user_role.name}" => assigned
              }
          )
        end
      end

      # Tracks user sessions in bullet train
      class UserSessionTracker
        # include Events::Consumer

        # consumes_event! 'user_sessions.create'

        def self.refresh(changed_since)
          return if changed_since.nil?
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          User.where('updated_at > ?', changed_since)
              .where(company_id: 2)
              .where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
              .find_in_batches do |batch|
            UserSession.where(user_id: batch.pluck(:id)).group(:user_id).count.each do |user_id, count|
              Rails.configuration.bullet_train&.set_trait "user:#{user_id}", 'user_sessions', count
            end
          end
        end

        def work(current_user, payload)
          user_session = payload[:record]
          return if user_session.blank?
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          Rails.configuration.bullet_train&.incr_counter user.analytics_id, 'user_sessions'
        end
      end

      # Responsible for refreshing all user traits
      class RefreshUserTraits

        def self.call(timeframe = 10.years.ago)
          return if Rails.configuration.bullet_train.nil? and Rails.configuration.posthog.nil?

          # Set company specific traits for all users
          Masters::Users::TraitPublisher::CompanyHandler.refresh(timeframe)

          # Set user traits for all users
          Masters::Users::TraitPublisher::UserHandler.refresh(timeframe)

          # Set role traits for all users
          Masters::Users::TraitPublisher::UserRoleHandler.refresh(timeframe)

          # Track user logins / sessions
          Masters::Users::TraitPublisher::UserSessionTracker.refresh(timeframe)
        end

      end
    end
  end
end