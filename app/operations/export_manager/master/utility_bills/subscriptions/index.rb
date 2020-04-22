class ExportManager::Master::UtilityBills::Subscriptions::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Utility Bill Masters'
  configurable true
  system :vp
  screen 'utility_subscriptions.index'
  resolver 'utility_subscriptions.default'
  handle :utility_bill_masters

  attribute :id
  attribute :bbps_biller_id
  attribute :name
  attribute :sequence_id
  attribute :department
  attribute :cost_center
  attribute :location
  attribute :policy
  attribute :active
  attribute :note
  attribute :created_at
  attribute :last_updated_at
  attribute :status
  attribute :created_by
  attribute :current_approval_level
  attribute :awaiting_approval_from
  attribute :expected_bill_day
  attribute :reminder_before_days
  attribute :biller_category_name
  attribute :submitted_at
  attribute :approved_at
  attribute :mobile_number
  attribute :customer_param_key_1
  attribute :customer_param_value_1
  attribute :customer_param_key_2
  attribute :customer_param_value_2
  attribute :customer_param_key_3
  attribute :customer_param_value_3
  attribute :customer_param_key_4
  attribute :customer_param_value_4
  attribute :customer_param_key_5
  attribute :customer_param_value_5
  attribute :bill_generation_type
  attribute :bill_validation_supported
  attribute :customer_name
  attribute :customer_email
  attribute :customer_aadhar_number
  attribute :customer_pan
  attribute :tax_rate
  attribute :category
  attribute :hsn_sac
  attribute :last_paid_at
  attribute :number_of_bills_present
  attribute :number_of_bills_paid

  def id(record)
    record.id
  end

  def bbps_biller_id(record)
    record.biller.biller_id
  end

  def bbps_biller(record)
    record.biller.biller_name
  end

  def name(record)
    record.name
  end

  def sequence_id(record)
    record.sequence_id
  end

  def department(record)
    record.department&.name
  end

  def cost_center(record)
    record.cost_center&.name
  end

  def location(record)
    record.location&.name
  end

  def policy(record)
    record.policy&.name
  end

  def active(record)
    record.active ? "Y" : "N"
  end

  def note(record)
    record.note
  end

  def created_at(record)
    record.created_at.strftime("%I:%M %p, %d %b %Y")
  end

  def last_updated_at(record)
    record.updated_at.strftime("%I:%M %p, %d %b %Y")
  end

  def status(record)
    record.status&.name
  end

  def created_by(record)
    "#{record.user&.name}\n#{record.user&.email}"
  end

  def current_approval_level(record)
    record.awaiting_approval? ? "#{record.level&.level_number} - #{record.level&.name}" : "NA"
  end

  def awaiting_approval_from(record)
    if record.awaiting_approval?
      record.get_reviewers.map {|user| "#{user.name}\n#{user.email}\n"}.join("\n")
    else
      "NA"
    end
  end

  def expected_bill_day(record)
    record.expected_bill_day
  end

  def reminder_before_days(record)
    record.reminder_before_days
  end

  def biller_category_name(record)
    record.biller_category_name
  end

  def submitted_at(record)
    record.draft? ? "NA" : record.submitted_at&.strftime("%I:%M %p, %d %b %Y")
  end

  def approved_at(record)
    BbpsBillerSubscriptionStatus.ids_for(:approved, :auto_approved, :activated, :deactivated).include?(record.status_id) ? record.approved_at&.strftime("%I:%M %p, %d %b %Y") : "NA"
  end

  def mobile_number(record)
    record.mobile_number
  end

  def customer_param_key_1(record)
    record.customer_param_key_1
  end

  def customer_param_value_1(record)
    record.customer_param_value_1
  end

  def customer_param_key_2(record)
    record.customer_param_key_2
  end

  def customer_param_value_2(record)
    record.customer_param_value_2
  end

  def customer_param_key_3(record)
    record.customer_param_key_3
  end

  def customer_param_value_3(record)
    record.customer_param_value_3
  end

  def customer_param_key_4(record)
    record.customer_param_key_4
  end

  def customer_param_value_4(record)
    record.customer_param_value_4
  end

  def customer_param_key_5(record)
    record.customer_param_key_5
  end

  def customer_param_value_5(record)
    record.customer_param_value_5
  end

  def bill_generation_type(record)
    %w(MANDATORY OPTIONAL).include?(record.fetch_requirement) ? "Auto Fetched" : "Manually Created"
  end

  def bill_validation_supported(record)
    %w(MANDATORY).include?(record.support_bill_validation) ? "Mandatory" : "Optional / Not Required"
  end

  def customer_name(record)
    record.customer_name
  end

  def customer_email(record)
    record.customer_email
  end

  def customer_aadhar_number(record)
    record.customer_aadhar_number
  end

  def customer_pan(record)
    record.customer_pan
  end

  def tax_rate(record)
    if record.tax_rate.present?
      "#{record.tax_rate&.name} - #{record.tax_rate&.rate}%"
    end
  end

  def category(record)
    record.category&.name
  end

  def hsn_sac(record)
    record.hsn_sac
  end

  def last_paid_at(record)
    record.last_paid_at&.strftime("%I:%M %p, %d %b %Y")
  end

  def number_of_bills_present(record)
    record.bbps_bills.count
  end

  def number_of_bills_paid(record)
    record.bbps_bills.filter_status('paid').count
  end

end