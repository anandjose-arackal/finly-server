class Docs::P2P::CreditNotes::Contracts::Update < Reform::Form
  property :id
  property :policy_id, validates: {presence: true}
  property :narration
  property :credit_note_number, validates: {presence: true}
  property :credit_note_date

  property :current_user, virtual: true

  collection :items, populator: :items! do
    property :id, validates: {presence: true}
    property :credit_note_item_type_id, validates: {presence: true}
    property :comment
    property :quantity, validates: {presence: true}
    property :rate, validates: {presence: true}
    property :tax_rate_id, validates: {presence: true}
  end

  validate :company_entities # Checks for departments

  private

  def items!(collection:, fragment:, index:, options:, **)
    item = items.find {|item| item.id.to_s == fragment["id"].to_s}

    if fragment["_destroy"]
      items.destroy(item)
      return skip!
    end

    # item ? items.insert(index, item.model) : items.insert(index, CreditNoteItem.new)
    item || items << CreditNoteItem.new
  end

  def company_entities
    params = {filter_role_id: [UserRole.id_for(:credit_note_initiator)], current_app: :vp}
    errors.add(:policy_id, "Invalid Policy") unless ::Policy::VendorPayments::Index.(current_user, params).policies.find_by(id: policy_id).present?
    true
  end
end