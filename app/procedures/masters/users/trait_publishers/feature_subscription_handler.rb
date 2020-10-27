# Responsible for publishing company properties
class Masters::Users::TraitPublishers::FeatureSubscriptionHandler < Masters::Users::TraitPublisher

  FEATURE_MAP = {
      product_em: {features: [:expense_management_enabled], user_subscriptions: [:expense_management]},
      product_vp: {features: [:yes_bank_account], user_subscriptions: [:yes_bank_account_transfer]},
      role_em_admin: {features: [:expense_management_enabled], user_subscriptions: [:expense_management], permissions: [:em_admin]},
      role_vp_admin: {features: [:yes_bank_account], user_subscriptions: [:yes_bank_account_transfer], permissions: [:vp_admin]},
      module_i2p: {features: [:yes_bank_account], user_subscriptions: [:yes_bank_account_transfer]},
      module_p2p: {features: [:yes_bank_account, :procurement], user_subscriptions: [:yes_bank_account_transfer], permissions: Docs::P2P::PurchaseRequests::Index.permissions},
      module_abp: {features: [:yes_bank_account, :agreement_based_payment_system], user_subscriptions: [:yes_bank_account_transfer], permissions: Docs::P2P::Agreements::Index.permissions},
      module_budgets: {features: [:budgeting_system], user_subscriptions: [:yes_bank_account_transfer], permissions: [:vp_admin, :budget_manager]},
      module_payments: {features: [:yes_bank_account, :current_account_connected], user_subscriptions: [:yes_bank_account_transfer]},
  }.freeze

  def self.refresh(changed_since, dry_run: false, options: {})
    return unless enabled?

    start_time = Time.now
    records = FeatureSubscription.where('updated_at > ?', changed_since)
    records.includes(:subscribable).each do |feature_subscription|
      new.work(nil, {record: feature_subscription, dry_run: dry_run, options: options})
    end
    logger.info(
        {handler: self.name, action: 'Refresh Completed', changed_since: changed_since, started_at: start_time,
         ended_at: Time.now, total_time: (Time.now - start_time).to_f,
         records_updated: records.count, total_records: records.count}
    )
  end

  def self.properties(user)
    json = {}
    FEATURE_MAP.each do |access, config|
      next unless company_subscribed?(user, config[:features]) if config[:features].present?
      next unless user_subscribed?(user, config[:user_subscriptions]) if config[:user_subscriptions].present?
      next unless user.has_permission?(config[:permissions]) if config[:permissions].present?

      json[access] = true
    end
    json
  end

  def work(u, payload)
    feature_subscription = payload[:record]
    company = feature_subscription.subscribable
    return false unless enabled?(company.id)

    users = company.users.where.not(company_id: IGNORE_LIST)
    users = users.limit(100) if payload[:dry_run]
    total_users = company.users.count
    completed_users = 0
    start_time = Time.now
    users = users.includes({company: :feature_subscription}, :user_panel_subscription, :policy_user_roles, :role_mapping)

    users.find_in_batches(batch_size: 1000) do |batch|
      batch_start = Time.now
      batch.each do |user|
        properties = self.class.properties(user)
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

  def self.company_subscribed?(user, features)
    return true unless features.present?

    features.each do |feature|
      return false unless !!user.company.feature_subscription.send(feature)
    end

    true
  end

  def self.user_subscribed?(user, user_subscriptions)
    return true unless user_subscriptions.present?

    user_subscriptions.each do |subscription|
      return false unless !!user.user_panel_subscription.send(subscription)
    end

    true
  end
end