class Docs::UtilityBills::Bills::Contracts::Update < Docs::UtilityBills::Bills::Contracts::Base

  property :id
  property :sequence_id
  property :policy_id, presence: true

  property :amount, populate_if_empty: Amount do
    property :value, presence: true
    property :currency_id, presence: true
  end

  private

end