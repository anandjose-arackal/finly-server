class Docs::P2P::CreditNotes::Contracts::Create < Reform::Form

  property :id
  property :company_id, presence: true
  property :user_id, presence: true
  property :policy_id, presence: true
  property :department_id, presence: true
  property :cost_center_id, presence: true
  property :billing_location_id, presence: true
  property :shipping_location_id, presence: true
  property :vendor_id, presence: true
  property :narration

  validate :company_entities # Checks for departments
  # validate :related_entities # Checks for associated agreements, users provided inside pocs
  validate :validate_customer_params

  # validate :company_specific_entities

  def company_entities
    params = {filter_role_id: [UserRole.id_for(:credit_note_initiator)], current_app: :vp}
    # errors.add(:department_id, "Invalid Department") unless Company::Departments::Index.(current_user, params).policy_department_filter_mapping&.leaves&.pluck(:id)&.include?(department_id.to_i)
    # errors.add(:cost_center_id, "Invalid Cost Center") unless current_user.company.cost_centers&.pluck(:id).include?(cost_center_id.to_i)
    # errors.add(:location_id, "Invalid Location") unless Company::Locations::Index.(current_user, params).policy_location_filter_mapping&.leaves&.pluck(:id)&.include?(location_id.to_i)
    errors.add(:policy_id, "Invalid Policy") unless ::Policy::VendorPayments::Index.(current_user, params).policies.find_by(id: policy_id).present?

    if agreement_id.present?
      errors.add(:agreement_id, "Invalid Agreement Details") unless current_user.company.payment_agreements.find_by(id: agreement_id).present?
    end
  end

  private
end