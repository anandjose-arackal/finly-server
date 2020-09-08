class ExportManager::Master::UtilityBills::Bills::Index < ExportManager::Builders::Template

  label 'Spreadsheet'
  description 'Utility Bills'
  export_format 'csv'
  resource 'utility_bills'
  subscribe 'utility_bills'
  default true

  attribute :id, template: '{{ record.id }}'
  attribute :bill_sequence_id, template: '{{ record.bill_id }}'
  attribute :subscription_id, template: '{{ record.subscription.id }}'
  attribute :subscription_sequence_id, template: '{{ record.subscription.subscription_id }}'
  attribute :subscription_name, template: '{{ record.subscription.name }}'
  attribute :bbps_biller_id, template: '{{ record.subscription.biller.biller_id }}'
  attribute :point_of_contacts, template: '{% for user in record.subscription.pocs %}{{user.name}} {{user.email}}, {% endfor %}'
  attribute :assignee, template: '{{ record.user.name }} {{ record.user.email }}'
  attribute :department, template: '{{ record.department.name }}'
  attribute :cost_center, template: '{{ record.cost_center.name }}'
  attribute :location, template: '{{ record.location.name }}'
  attribute :policy, template: '{{ record.policy.name }}'
  attribute :current_approval_level, template: '{% if record.awaiting_approval %}{{ record.level.level_number }} - {{ record.level.name }}{% else %}NA{%endif%}'
  attribute :awaiting_approval_from, template: '{% if record.awaiting_approval %}{% for user in record.get_reviewers %}{{ record.user.name }} - {{ record.user.email }}, {% endfor %}{% else %}NA{% endif %}'
  attribute :mobile_number, template: '{{ record.subscription.mobile_number }}'
  attribute :customer_param_key_1, template: '{{ record.subscription.customer_param_key_1 }}'
  attribute :customer_param_value_1, template: '{{ record.subscription.customer_param_value_1 }}'
  attribute :customer_param_key_2, template: '{{ record.subscription.customer_param_key_2 }}'
  attribute :customer_param_value_2, template: '{{ record.subscription.customer_param_value_2 }}'
  attribute :customer_param_key_3, template: '{{ record.subscription.customer_param_key_3 }}'
  attribute :customer_param_value_3, template: '{{ record.subscription.customer_param_value_3 }}'
  attribute :customer_param_key_4, template: '{{ record.subscription.customer_param_key_4 }}'
  attribute :customer_param_value_4, template: '{{ record.subscription.customer_param_value_4 }}'
  attribute :customer_param_key_5, template: '{{ record.subscription.customer_param_key_5 }}'
  attribute :customer_param_value_5, template: '{{ record.subscription.customer_param_value_5 }}'
  attribute :bill_generation_type, template: '{% if record.auto_fetched %}Auto Fetched{% else %}Manually Created{% endif %}'
  attribute :bill_validation_supported, template: '{% if record.subscription.support_bill_validation == "MANDATORY" %}Mandatory{% else %}Optional / Not Required{% endif %}'
  attribute :status, template: '{{ record.status.name }}'
  attribute :amount, template: '{{ record.amount.value }}'
  attribute :early_payment_fee_selected, template: '{{ record.early_payment_fee_selected }}'
  attribute :late_payment_fee_selected, template: '{{ record.late_payment_fee_selected }}'
  attribute :convenience_fee_selected, template: '{{ record.convenience_fee_selected }}'
  attribute :late_payment_fee_id, template: '{{ record.late_payment_fee.value }}'
  attribute :early_payment_fee_id, template: '{{ record.early_payment_fee.value }}'
  attribute :convenience_fee_id, template: '{{ record.convenience_fee.value }}'
  attribute :total_amount_id, template: '{{ record.total_amount.value }}'
  attribute :expected_due_date, template: '{{ record.expected_due_date | date: "%d-%d-%Y" }}'
  attribute :created_at, template: '{{ record.created_at | date: "%I:%M %p, %d %b %Y" }}'
  attribute :last_updated_at, template: '{{ record.updated_at | date: "%I:%M %p, %d %b %Y" }}'
  attribute :submitted_at, template: '{{ record.submitted_at | date: "%I:%M %p, %d %b %Y" }}'
  attribute :approved_at, template: '{{ record.approved_at | date: "%I:%M %p, %d %b %Y" }}'
  attribute :note, template: '{{ record.note }}'
  attribute :due_date, template: "{{ record.due_date | date: '%d-%b-%Y' }}"
  attribute :bill_date, template: '{{ record.bill_date | date: "%d-%b-%Y" }}'
  attribute :bill_number, template: '{{ record.bill_number }}'
  attribute :paid_on_date, template: '{% if record.is_paid %}{{ record.paid_on_date | date: "%d-%b-%Y" }}{%endif%}'
  attribute :transaction_id, template: '{{ record.transaction_id }}'
  attribute :bbps_id, template: '{{ record.bbps_id }}'
  attribute :bill_period, template: '{{ record.bill_period }}'
  attribute :customer_name, template: '{{ record.subscription.customer_name }}'
  attribute :customer_email, template: '{{ record.subscription.customer_email }}'
  attribute :customer_aadhar_number, template: '{{ record.subscription.customer_aadhar_number }}'
  attribute :customer_pan, template: '{{ record.subscription.customer_pan }}'
  attribute :tax_rate, template: '{{record.tax_rate.name}} - {{record.tax_rate.rate}}'
  attribute :category, template: '{{ record.category.name }}'
  attribute :hsn_sac, template: '{{ record.hsn_sac }}'
  attribute :paid_at, template: '{% if record.is_paid %}{{ record.paid_at | date: "%I:%M %p, %d %b %Y" }}{% else %}NA{%endif%}'

  # def id(record)
  #   record.id
  # end

  # def bill_sequence_id(record)
  #   record.sequence_id
  # end

  # def subscription_id(record)
  #   record.subscription.id
  # end

  # def subscription_sequence_id(record)
  #   record.subscription.sequence_id
  # end

  # def subscription_name(record)
  #   record.subscription.name
  # end

  # def bbps_biller_id(record)
  #   record.subscription.biller.biller_id
  # end

  # def point_of_contacts(record)
  #   record.subscription.pocs.map {|user| "#{user.name}\n#{user.email}\n"}.join("\n")
  # end

  # def assignee(record)
  #   "#{record.user&.name}\n#{record.user&.email}"
  # end

  # def department(record)
  #   record.department&.name
  # end

  # def cost_center(record)
  #   record.cost_center&.name
  # end

  # def location(record)
  #   record.location&.name
  # end

  # def policy(record)
  #   record.policy&.name
  # end

  # def current_approval_level(record)
  #   record.awaiting_approval? ? "#{record.level&.level_number} - #{record.level&.name}" : "NA"
  # end

  # def awaiting_approval_from(record)
  #   if record.awaiting_approval?
  #     record.get_reviewers.map {|user| "#{user.name}\n#{user.email}\n"}.join("\n")
  #   else
  #     "NA"
  #   end
  # end

  # def mobile_number(record)
  #   record.subscription.mobile_number
  # end

  # def customer_param_key_1(record)
  #   record.subscription.customer_param_key_1
  # end

  # def customer_param_value_1(record)
  #   record.subscription.customer_param_value_1
  # end

  # def customer_param_key_2(record)
  #   record.subscription.customer_param_key_2
  # end

  # def customer_param_value_2(record)
  #   record.subscription.customer_param_value_2
  # end

  # def customer_param_key_3(record)
  #   record.subscription.customer_param_key_3
  # end

  # def customer_param_value_3(record)
  #   record.subscription.customer_param_value_3
  # end

  # def customer_param_key_4(record)
  #   record.subscription.customer_param_key_4
  # end

  # def customer_param_value_4(record)
  #   record.subscription.customer_param_value_4
  # end

  # def customer_param_key_5(record)
  #   record.subscription.customer_param_key_5
  # end

  # def customer_param_value_5(record)
  #   record.subscription.customer_param_value_5
  # end

  # def bill_generation_type(record)
  #   record.autofetched ? "Auto Fetched" : "Manually Created"
  # end

  # def bill_validation_supported(record)
  #   %w(MANDATORY).include?(record.subscription.support_bill_validation) ? "Mandatory" : "Optional / Not Required"
  # end

  # def status(record)
  #   record.status&.name
  # end

  # def amount(record)
  #   record.amount.value
  # end

  # def early_payment_fee_selected(record)
  #   record.early_payment_fee_selected ? "Yes" : "No"
  # end

  # def early_payment_fee_id(record)
  #   record.early_payment_fee&.value
  # end

  # def late_payment_fee_selected(record)
  #   record.late_payment_fee_selected ? "Yes" : "No"
  # end

  # def late_payment_fee_id(record)
  #   record.late_payment_fee&.value
  # end

  # def convenience_fee_selected(record)
  #   record.convenience_fee_selected ? "Yes" : "No"
  # end

  # def convenience_fee_id(record)
  #   record.convenience_fee&.value ? "Yes" : "No"
  # end

  # def total_amount_id(record)
  #   record.total_amount&.value
  # end

  # def expected_due_date(record)
  #   record.expected_due_date&.strftime("%d-%b-%Y")
  # end

  # def created_at(record)
  #   record.created_at.strftime("%I:%M %p, %d %b %Y")
  # end

  # def last_updated_at(record)
  #   record.updated_at.strftime("%I:%M %p, %d %b %Y")
  # end

  # def submitted_at(record)
  #   record.open? ? "NA" : record.submitted_at.strftime("%I:%M %p, %d %b %Y")
  # end

  # def approved_at(record)
  #   BbpsBillStatus.ids_for(:open, :retracted, :rejected, :awaiting_approval).include?(record.status_id) ? "NA" : record.approved_at&.strftime("%I:%M %p, %d %b %Y")
  # end

  # def note(record)
  #   record.note
  # end

  # def due_date(record)
  #   record.due_date
  # end

  # def bill_date(record)
  #   record.bill_date
  # end

  # def bill_number(record)
  #   record.bill_number
  # end

  # def paid_on_date(record)
  #   record.paid_on_date if record.paid?
  # end

  # def transaction_id(record)
  #   record.transaction_id
  # end

  # def bbps_id(record)
  #   record.bbps_id
  # end

  # def bill_period(record)
  #   record.bill_period
  # end

  # def customer_name(record)
  #   record.subscription.customer_name
  # end

  # def customer_email(record)
  #   record.subscription.customer_email
  # end

  # def customer_aadhar_number(record)
  #   record.subscription.customer_aadhar_number
  # end

  # def customer_pan(record)
  #   record.subscription.customer_pan
  # end

  # def tax_rate(record)
  #   if record.tax_rate.present?
  #     "#{record.tax_rate&.name} - #{record.tax_rate&.rate}%"
  #   end
  # end

  # def category(record)
  #   record.category&.name
  # end

  # def hsn_sac(record)
  #   record.hsn_sac
  # end

  # def paid_at(record)
  #   record.paid? ? record.paid_at&.strftime("%I:%M %p, %d %b %Y") : "NA"

  # end

end