class Docs::UtilityBills::Bills::Contracts::Update < Docs::UtilityBills::Bills::Contracts::Base
  property :id
  property :policy_id, validates: {presence: true}

  property :amount, populate_if_empty: Amount do
    property :value, validates: {presence: true}
    property :currency_id, validates: {presence: true}
  end
  private
end