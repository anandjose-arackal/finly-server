# For capturing user permissions and roles
class Masters::Users::TraitPublishers::UserRoleHandler < Masters::Users::TraitPublisher
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