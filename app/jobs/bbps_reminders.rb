class BbpsReminders < BaseJob

  def self.perform_job
    @logger = Logger.new "#{Rails.root}/log/reminders.log"
    @logger.info "#{self.name} => Job run started at #{Time.now}"

    user_for_master_flag = User.unscoped.first
    unless MasterFlagEmailRemindersAllCompanyToggle.new(user_for_master_flag).enabled?
      @logger.info "#{self.name} => Master flag has prevented the job execution at #{Time.now}"
      return
    end

    fetch_due_bills
    find_pocs
    organize_bills_by_users
    find_users

    if @bills_due.present? and @users.present?
      trigger_mailer_event
    else
      @logger.info "#{self.name} => No bills found for today's due date at #{Time.now}"
    end
    
    # @logger.info "#{self.name} => Job run ended at #{Time.now}"
  end

  private

  def self.fetch_due_bills
    @bills_due ||= BbpsBill
      .distinct
      .select(selected_attributes)
      .joins(
        { subscription: :biller },
        { amount: :currency },
        :department,
        :cost_center,
        :location,
      )
      .filter_status(:payables)
      .where("DATEDIFF(`bbps_bills`.`due_date`, ?) = `bbps_biller_subscriptions`.`reminder_before_days`", Date.today)
      .group_by(&:bbps_bill_id)
      .transform_values(&:first)
    # Not using 'filter_status(:payables)' method because it works with amount but we need total amount here
  end

  def self.selected_attributes
    [
      "`bbps_bills`.`id` AS `bbps_bill_id`",
      "`bbps_bills`.`due_date` AS `bbps_bill_due_date`",
      "`bbps_bills`.`bill_number` AS `bbps_bill_number`",
      "`bbps_bills`.`created_at`",
      "`bbps_bills`.`autofetched`",

      "`bbps_billers`.`biller_name` AS `bbps_biller_name`",
      "`bbps_billers`.`biller_category_name` AS `bbps_biller_category_name`",
      
      "`bbps_biller_subscriptions`.`name` AS `bbps_subscription_name`",
      "`bbps_biller_subscriptions`.`reminder_before_days` AS `bbps_subscription_reminder_before_days`",

      "`amounts`.`value` AS `base_amount_value`",
      "`currencies`.`country_code` AS currency_country_code",

      "`departments`.`name` AS `department_name`",
      "`cost_centers`.`name` AS `cost_center_name`",
      "`branch_locations`.`name` AS `location_name`"
    ]
  end

  def self.find_pocs
    return unless @bills_due.present?

    @bbps_pocs ||= BbpsBill
                    .unscope(:order)
                    .distinct
                    .select(
                      "`bbps_bills`.`id`",
                      "`users`.id AS `poc_id`",
                      "`document_level_reviewer_mappings`.`reviewer_id` AS `dlrm_reviewer_id`",
                      # "`document_level_reviewer_mappings`.`forwarded_to_id` AS `dlrm_forwarded_to_id`",
                      # "`document_level_reviewer_mappings`.`taken_control_by_id` AS `dlrm_taken_control_by_id`",
                    )
                    .joins({ subscription: :pocs }, :document_level_reviewer_mappings)
                    .where(id: @bills_due.keys)
  end

  def self.organize_bills_by_users
    return unless @bbps_pocs.present?

    @bills_by_users = {}
    
    @bbps_pocs.each do |bill|
      @bills_by_users[bill.id] = [] if @bills_by_users[bill.id].blank?

      @bills_by_users[bill.id] << bill.poc_id
      @bills_by_users[bill.id] << bill.dlrm_reviewer_id
      # @bills_by_users[bill.id] << bill.dlrm_forwarded_to_id
      # @bills_by_users[bill.id] << bill.dlrm_taken_control_by_id
    end

    @bills_by_users = @bills_by_users.transform_values { |user_ids_list| user_ids_list.uniq.compact }
  end

  def self.find_users
    return unless @bills_by_users.present?

    user_ids = []
    
    @bills_by_users.each do |bill_id, user_ids_list|
      user_ids += user_ids_list
    end
    
    user_ids = user_ids.uniq.compact
    
    user_attributes = [
      "`users`.`id`",
      "`users`.`first_name`",
      "`users`.`last_name`",
      "`users`.`email`",
      "`users`.`company_id`",
    ]
    
    if user_ids.present?
      @users ||= User.includes(:company).where(id: user_ids).select(user_attributes)
                     .group_by(&:id).transform_values(&:first)
    end
  end

  def self.trigger_mailer_event
    return unless @bills_by_users.present?

    @bills_by_users.each do |bill_id, user_ids_list|

      bill = @bills_due[bill_id]

      params = {
        bill_id: bill.bbps_bill_id,
        utility_operator_or_vendor: bill.bbps_biller_name,
        utility_title: bill.bbps_subscription_name,
        due_date: bill.bbps_bill_due_date,
        bill_type: bill.bbps_biller_category_name,
        bill_amount: bill.base_amount_value,
        currency_country_code: bill.currency_country_code,
        bill_number: bill.bbps_bill_number,
        department: bill.department_name,
        cost_center: bill.cost_center_name,
        location: bill.location_name
      }

      user_ids_list.each do |user_id|
        user = @users[user_id]
        
        Event::EReminders::BbpsSubscription.(user, params)
      end
    end
  end
end

# ==begin
#     To : Point of contact
#     Subject : Reminder - Payment for [Utility] Bill Due
#
#   Dear Sir/Mam,
#     This is a reminder that the payment for your [Utility title] bill due on [Due Date].
#     Below are the additional Details of the bill.
#
#     Bill type : (Electricity/telephone Etc)
#     Operator/Vendor : (Operator/Vendor Name)
#     Bill amount : (Bill Amount as per invoice)
#     Invoice No: (Invoice No as per invoice)
#     Department : (Department Name)
#     Cost Center : (Cost Center Name)
#     Location: (Location Name)
#
#     Click here for more Details.
#
#     If you have already submitted your payment, please disregard this reminder.
#
#     Thanks,
#     Team Finly
