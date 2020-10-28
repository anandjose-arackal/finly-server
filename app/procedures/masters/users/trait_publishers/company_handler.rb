# Responsible for publishing company properties
class Masters::Users::TraitPublishers::CompanyHandler < Masters::Users::TraitPublisher

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

  def self.properties(company)
    {
        'company_id' => company.id,
        'company_name' => company.name,
        'company_active' => !!company.active,
        'company_subdomain' => company.subdomain,
        'company_test_account' => !!company.test_account,
        'company_group_name' => company.group&.name,
        'company_status' => company.status&.name,
        'company_deleted_at' => company.deleted_at,
    }.compact
  end

  def work(u, payload)
    company = payload[:record]
    return false unless enabled?(company.id)

    users = company.users.where.not(company_id: IGNORE_LIST)
    users = users.limit(100) if payload[:dry_run]
    total_users = company.users.count
    completed_users = 0
    start_time = Time.now

    properties = self.class.properties(company)

    users.find_in_batches(batch_size: 1000) do |batch|
      batch_start = Time.now
      batch.each do |user|
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