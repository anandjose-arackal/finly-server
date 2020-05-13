class BbpsBillExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :bill_id, record_attribute: :sequence_id
  attribute :subscription, record_attribute: true, exposure: true, includes: [:subscription]
  attribute :user, record_attribute: true, exposure: true, includes: [:user]
  attribute :created_by, record_attribute: :created_by, exposure: true, includes: [:created_by]
  attribute :status, record_attribute: true, exposure: true, includes: [:status]
  attribute :bill_number, record_attribute: true
  attribute :bill_date, record_attribute: true
  attribute :due_date, record_attribute: true
  attribute :due_in_days do
    next unless record.due_date.present?

    days = record.due_date - Date.today
    next if BbpsBillStatus.ids_for(:paid).include?(record.status_id)

    if days < 0
      "Overdue by #{days.abs.to_i} days"
    else
      "#{days.to_i} days"
    end
  end
  attribute :paid_at, record_attribute: true
  attribute :transaction_id, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true
  attribute :submitted_at, record_attribute: true
  attribute :approved_at, record_attribute: true
  attribute :total_amount, record_attribute: true, exposure: true, includes: [:total_amount]
  attribute :cost_center, record_attribute: true, exposure: true, includes: [:cost_center]
  attribute :location, record_attribute: true, exposure: true, includes: [:location]
  attribute :department, record_attribute: true, exposure: true, includes: [:department]
  attribute :controlling_level, record_attribute: true, exposure: true, includes: [:controlling_level]
  attribute :policy, record_attribute: true, exposure: true, includes: [:policy]
  attribute :auto_fetched, record_attribute: :autofetched
  attribute :tax_rate, record_attribute: true, exposure: true, includes: [:tax_rate]
  attribute :hsn_sac, record_attribute: true

end