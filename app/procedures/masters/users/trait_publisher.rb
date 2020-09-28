module Masters
  module Users
    module TraitPublisher
      # Production having very large number of users but not active at the moment
      IGNORE_LIST = [
          1, # Demo Account
          50, # Pro-align
          54 # Jotun India
      ]

      class CompanyHandler
        # include Events::Consumer

        # consumes_event! 'companies.*'

        def self.refresh(changed_since)
          return if Rails.configuration.bullet_train.nil?

          Company.where('updated_at > ?', changed_since).all.each do |c|
            new.work(nil, record: c)
          end
        end

        def work(current_user, payload)
          company = payload[:record]
          return if IGNORE_LIST.include?(company.id)
          return if Rails.configuration.bullet_train.nil?

          company.users.where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST).find_each do |user|
            posthog_properties = {}
            if company.id.present?
              Rails.configuration.bullet_train.set_trait user.analytics_id, "company_id", company.id
              posthog_properties["company_id"] = company.id
            end
            if company.name.present?
              Rails.configuration.bullet_train.set_trait user.analytics_id, "company_name", company.name
              posthog_properties["company_name"] = company.name
            end
            Rails.configuration.bullet_train.set_trait user.analytics_id, "company_active", !!company.active
            posthog_properties["company_active"] = !!company.active
            if company.subdomain.present?
              Rails.configuration.bullet_train.set_trait user.analytics_id, "company_subdomain", company.subdomain
              posthog_properties["company_subdomain"] = company.subdomain
            end
            Rails.configuration.bullet_train.set_trait user.analytics_id, "company_test_account", !!company.test_account
            posthog_properties["company_test_account"] = !!company.test_account
            if company.group&.name.present?
              Rails.configuration.bullet_train.set_trait user.analytics_id, "company_group_name", company.group&.name
              posthog_properties["company_group_name"] = company.group&.name
            end
            if company.status&.name.present?
              Rails.configuration.bullet_train.set_trait user.analytics_id, "company_status", company.status&.name
              posthog_properties["company_status"] = company.status&.name
            end
            unless company.deleted_at.nil?
              Rails.configuration.bullet_train.set_trait user.analytics_id, 'company_deleted_at', company.deleted_at
              posthog_properties['company_deleted_at'] = company.deleted_at
            end

            Rails.configuration.posthog.identify(
                distinct_id: user.analytics_id,
                properties: posthog_properties
            )

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
          return if Rails.configuration.bullet_train.nil?

          User.where('updated_at > ?', changed_since)
              .where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
              .limit(1)
              .find_each do |user|
            self.new.work(nil, record: user)
          end
        end

        def work(current_user, payload)
          return if Rails.configuration.bullet_train.nil?

          user = payload[:record]
          return if Masters::Users::TraitPublisher::IGNORE_LIST.include?(user.company_id)

          posthog_properties = {}

          if user.email.present?
            Rails.configuration.bullet_train.set_trait user.id, 'email', user.email
            posthog_properties['email'] = user.email
          end
          if user.mobile_number.present?
            Rails.configuration.bullet_train.set_trait user.id, 'mobile_number', user.mobile_number
            posthog_properties['mobile_number'] = user.mobile_number
          end
          if user.first_name.present?
            Rails.configuration.bullet_train.set_trait user.id, 'first_name', user.first_name
            posthog_properties['first_name'] = user.first_name
          end
          if user.last_name.present?
            Rails.configuration.bullet_train.set_trait user.id, 'last_name', user.last_name
            posthog_properties['last_name'] = user.last_name
          end
          unless user.deleted_at.nil?
            Rails.configuration.bullet_train.set_trait user.id, 'deleted_at', user.deleted_at
            posthog_properties['deleted_at'] = user.deleted_at
          end

          Rails.configuration.bullet_train.set_trait user.id, 'verified', !!user.verified
          posthog_properties['verified'] = !!user.verified
          Rails.configuration.bullet_train.set_trait user.id, 'has_set_password', !!user.default_password
          posthog_properties['has_set_password'] = !!user.default_password
          Rails.configuration.bullet_train.set_trait user.id, 'point_of_contact', !!user.point_of_contact
          posthog_properties['point_of_contact'] = !!user.point_of_contact
          Rails.configuration.bullet_train.set_trait user.id, 'otp_verified', !!user.otp_verified
          posthog_properties['otp_verified'] = !!user.otp_verified
          Rails.configuration.bullet_train.set_trait user.id, 'status', user.status
          posthog_properties['status'] = user.status

          Rails.configuration.posthog.identify(
              distinct_id: user.analytics_id,
              properties: posthog_properties
          )
          true
        end
      end

      # For capturing user permissions and roles
      class UserRoleHandler
        # include Events::Consumer

        # consumes_event! 'user_role_mappings.*', 'policy_user_roles.*'

        def self.refresh(changed_since)
          return if changed_since.nil?
          return if Rails.configuration.bullet_train.nil?

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
          return if Rails.configuration.bullet_train.nil?

          role_mapping = payload[:record]
          return if IGNORE_LIST.include?(role_mapping.user.company_id)
          return if role_mapping.user_role&.name.blank?

          # Role is assigned to the user if the deleted_at flag is not set
          assigned = role_mapping.deleted_at.nil?
          Rails.configuration.bullet_train.set_trait user.id, "permission_#{role_mapping.user_role.name}", assigned
          Rails.configuration.posthog.identify(
              distinct_id: user.analytics_id,
              properties: {
                  "permission_#{role_mapping.user_role.name}" => assigned
              }
          )
        end
      end

      class UserSessionTracker
        # include Events::Consumer

        # consumes_event! 'user_sessions.create'

        def self.refresh(changed_since)
          return if changed_since.nil?
          return if Rails.configuration.bullet_train.nil?

          User.where('updated_at > ?', changed_since)
              .where(company_id: 2)
              .where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
              .find_in_batches do |batch|
            UserSession.where(user_id: batch.pluck(:id)).group(:user_id).count.each do |user_id, count|
              Rails.configuration.bullet_train.set_trait user_id, 'user_sessions', count
            end
          end
        end

        def work(current_user, payload)
          user_session = payload[:record]
          return if user_session.blank?

          Rails.configuration.bullet_train.incr_counter user.id, 'user_sessions'
        end
      end

      class RefreshUserTraits

        def self.call(timeframe=10.years.ago)
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