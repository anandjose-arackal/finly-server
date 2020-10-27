# Responsible for publishing company properties
class Masters::Users::TraitPublishers::UserSubscriptionHandler < Masters::Users::TraitPublishers::FeatureSubscriptionHandler

  def self.refresh(changed_since, dry_run: false, options: {})
    return unless enabled?

    start_time = Time.now
    records = UserPanelSubscription.where('updated_at > ?', changed_since)
    completed_users = 0
    total_users = records.count
    records = records.includes(user: [{company: :feature_subscription}, :user_panel_subscription, :policy_user_roles, :role_mapping])

    records.find_in_batches(batch_size: 1000) do |batch|
      batch_start_time = Time.now
      batch.each do |user_panel_subscription|
        new.work(nil, {record: user_panel_subscription, dry_run: dry_run, options: options})
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
        {handler: self.name, action: 'Refresh Completed', changed_since: changed_since, started_at: start_time,
         ended_at: Time.now, total_time: (Time.now - start_time).to_f,
         records_updated: completed_users, total_records: total_users}
    )
  end

  def work(u, payload)
    user_panel_subscription = payload[:record]
    user = user_panel_subscription.user
    return false unless enabled?(user.company_id)

    publish(self.class, user, self.class.properties(user), options: payload[:options])
    true
  end

end