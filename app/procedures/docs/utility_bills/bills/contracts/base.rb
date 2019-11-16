class Docs::UtilityBills::Bills::Contracts::Base < Reform::Form

  property :id
  property :subscription_id #, presence: true
  property :sequence_id

  property :department_id
  property :cost_center_id
  property :location_id
  property :company_id, presence: true

  # property :user_id, presence: true

  property :status_id, default: BbpsBillStatus.id_for(:open)

  property :amount, populate_if_empty: Amount do
    property :value, presence: true, default: 0
    property :currency_id, presence: true
  end

end