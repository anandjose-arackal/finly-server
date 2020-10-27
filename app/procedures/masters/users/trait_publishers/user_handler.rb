# Updates the user and user profile attributes by using the +users.create+ and +users.update+ hooks.
class Masters::Users::TraitPublishers::UserHandler < Masters::Users::TraitPublisher

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

  def self.properties(user)
    {
        'email' => user.email,
        'mobile_number' => user.mobile_number,
        'first_name' => user.first_name,
        'last_name' => user.last_name,
        'deleted_at' => user.deleted_at,
        'point_of_contact' => !!user.point_of_contact,
        'status' => user.status
    }.compact
  end

  def work(user, payload)
    user = payload[:record]
    return unless enabled?(user.company_id)

    publish(self.class, user, self.class.properties(user), options: payload[:options])
    true
  end
end