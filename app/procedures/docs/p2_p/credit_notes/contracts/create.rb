class Docs::P2P::CreditNotes::Contracts::Create < Transactions::Contract

  property :id
  property :company_id, validates: {presence: true}
  property :procurement_id, validates: {presence: true}
  property :user_id, validates: {presence: true}
  property :policy_id, validates: {presence: true}
  property :invoice_id, validates: {presence: true}
  property :department_id, validates: {presence: true}
  property :cost_center_id, validates: {presence: true}
  property :billing_location_id, validates: {presence: true}
  property :shipping_location_id, validates: {presence: true}
  property :vendor_id, validates: {presence: true}
  property :narration
  property :tds_rate_id

  property :current_user, virtual: true
  property :status_id, default: CreditNoteStatus.id_for(:draft)

  collection :items, populate_if_emtpy: CreditNoteItem, populator: :items! do
    # property :credit_note_item_type_id, validates:{ presence: true }
    property :item_id, validates: {presence: true}
    property :invoice_item_id, validates: {presence: true}
    property :category_id, validates: {presence: true}
    property :comment, validates: {presence: true}
    property :hsn_sac, presence: true
    property :original_quantity, validates: {presence: true}
    property :quantity, validates: {presence: true}
    property :original_rate, validates: {presence: true}
    property :rate, validates: {presence: true}
    property :original_taxable_amount, populate_if_empty: Amount do
      property :id
      property :value, validates: {presence: true}
      property :currency_id, validates: {presence: true}
    end
    property :taxable_amount, populate_if_empty: Amount do
      property :id
      property :value, validates: {presence: true}
      property :currency_id, validates: {presence: true}
    end

    property :original_tax_rate_id, validates: {presence: true}
    property :tax_rate_id, validates: {presence: true}
  end

  validate :company_entities # Checks for departments
  # validate :related_entities # Checks for associated agreements, users provided inside pocs

  # validate :company_specific_entities

  def company_entities
    params = {filter_role_id: [UserRole.id_for(:credit_note_initiator)], current_app: :vp}
    errors.add(:policy_id, "Invalid Policy") unless ::Policy::VendorPayments::Index.(current_user, params).policies.find_by(id: policy_id).present?
  end

  private

  # def items!(collection:, fragment:, index:, options:, **)
  #   item = items.find { |item| item.id.to_s == fragment["id"].to_s }
  #
  #
  #   if fragment["_destroy"]
  #     items.delete(item)
  #     return skip!
  #   end
  #
  #
  #   item ? items.insert(index, item.model) : items.insert(index, CreditNoteItem.new)
  # end

  def items!(collection:, fragment:, index:, options:, **)
    items.insert(index, CreditNoteItem.new)
  end
end