class Docs::P2P::CreditNotes::Contracts::Create < Reform::Form

  property :id
  # property :company_id, presence: true
  # property :user_id, presence: true
  property :policy_id, presence: true
  # property :department_id, presence: true
  # property :cost_center_id, presence: true
  # property :billing_location_id, presence: true
  # property :shipping_location_id, presence: true
  property :narration


  validate :company_entities # Checks for departments
  # validate :related_entities # Checks for associated agreements, users provided inside pocs
  validate :validate_customer_params

  # validate :company_specific_entities

  private
end