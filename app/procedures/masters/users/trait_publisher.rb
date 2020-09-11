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
        include Events::Consumer

        consumes_event! 'companies.*'

        def self.refresh(changed_since)
          return if BULLET_TRAIN.nil?

          Company.where('updated_at > ?', changed_since).all.each do |c|
            new.work(nil, record: c)
          end
        end

        def work(current_user, payload)
          company = payload[:record]
          return if IGNORE_LIST.include?(company.id)
          return if BULLET_TRAIN.nil?

          company.users.where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST).find_each do |user|
            BULLET_TRAIN.set_trait user.id, "company_id", company.id if company.id.present?
            BULLET_TRAIN.set_trait user.id, "company_name", company.name if company.name.present?
            BULLET_TRAIN.set_trait user.id, "company_active", !!company.active
            BULLET_TRAIN.set_trait user.id, "company_subdomain", company.subdomain if company.subdomain.present?
            BULLET_TRAIN.set_trait user.id, "company_test_account", !!company.test_account
            BULLET_TRAIN.set_trait user.id, "company_group_name", company.group&.name if company.group&.name.present?
            BULLET_TRAIN.set_trait user.id, "company_status", company.status&.name if company.status&.name.present?
            BULLET_TRAIN.set_trait user.id, 'company_deleted_at', company.deleted_at unless company.deleted_at.nil?

            true
          end
        end
      end

      # Updates the user and user profile attributes by using the +users.create+ and +users.update+ hooks.
      class UserHandler
        include Events::Consumer

        consumes_event! 'users.*'

        def self.refresh(changed_since)
          return if changed_since.nil?
          return if BULLET_TRAIN.nil?

          User.where('updated_at > ?', changed_since)
              .where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
              .find_each do |user|
            self.new.work(nil, record: user)
          end
        end

        def work(current_user, payload)
          return if BULLET_TRAIN.nil?

          user = payload[:record]
          return if Masters::Users::TraitPublisher::IGNORE_LIST.include?(user.company_id)

          BULLET_TRAIN.set_trait user.id, 'email', user.email if user.email.present?
          BULLET_TRAIN.set_trait user.id, 'mobile_number', user.mobile_number if user.mobile_number.present?
          BULLET_TRAIN.set_trait user.id, 'active', !!user.active
          BULLET_TRAIN.set_trait user.id, 'first_name', user.first_name if user.first_name.present?
          BULLET_TRAIN.set_trait user.id, 'last_name', user.last_name if user.last_name.present?
          BULLET_TRAIN.set_trait user.id, 'verified', !!user.verified
          BULLET_TRAIN.set_trait user.id, 'has_set_password', !!user.default_password
          BULLET_TRAIN.set_trait user.id, 'point_of_contact', !!user.point_of_contact
          BULLET_TRAIN.set_trait user.id, 'otp_verified', !!user.otp_verified
          BULLET_TRAIN.set_trait user.id, 'deleted_at', user.deleted_at unless user.deleted_at.nil?

          true
        end
      end

      # For capturing user permissions and roles
      class UserRoleHandler
        include Events::Consumer

        consumes_event! 'user_role_mappings.*', 'policy_user_roles.*'

        def self.refresh(changed_since)
          return if changed_since.nil?
          return if BULLET_TRAIN.nil?

          UserRoleMapping.where('user_role_mappings.updated_at > ?', changed_since)
              .includes(:user, :user_role)
              .joins(:user)
              .where.not(users: {company_id: Masters::Users::TraitPublisher::IGNORE_LIST})
              .find_each do |role_mapping|
            self.new.work(nil, record: role_mapping)
          end

          PolicyUserRole.where('policy_user_roles.updated_at > ?', changed_since)
              .includes(:user, :user_role)
              .joins(:user)
              .where.not(users: {company_id: Masters::Users::TraitPublisher::IGNORE_LIST})
              .find_each do |role_mapping|
            self.new.work(nil, record: role_mapping)
          end
        end

        def work(current_user, payload)
          return if BULLET_TRAIN.nil?

          role_mapping = payload[:record]
          return if IGNORE_LIST.include?(role_mapping.user.company_id)
          return if role_mapping.user_role&.name.blank?

          # Role is assigned to the user if the deleted_at flag is set
          assigned = role_mapping.deleted_at.nil?
          BULLET_TRAIN.set_trait user.id, "permission_#{role_mapping.user_role.name}", assigned
        end
      end

      class UserSessionTracker
        include Events::Consumer

        consumes_event! 'user_sessions.create'

        def self.refresh(changed_since)
          return if changed_since.nil?
          return if BULLET_TRAIN.nil?

          User.where('updated_at > ?', changed_since)
              .where(company_id: 2)
              .where.not(company_id: Masters::Users::TraitPublisher::IGNORE_LIST)
              .find_in_batches do |batch|
            UserSession.where(user_id: batch.pluck(:id)).group(:user_id).count.each do |user_id, count|
              BULLET_TRAIN.set_trait user_id, 'user_sessions', count
            end
          end
        end

        def work(current_user, payload)
          user_session = payload[:record]
          return if user_session.blank?

          BULLET_TRAIN.incr_counter user.id, 'user_sessions'
        end
      end

      class RefreshUserTraits

        def self.call
          return if BULLET_TRAIN.nil?

          timeframe = 10.years.ago
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