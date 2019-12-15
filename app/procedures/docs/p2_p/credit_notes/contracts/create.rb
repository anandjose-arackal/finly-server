class Docs::P2P::CreditNotes::Contracts::Create < Reform::Form

  property :id
  property :company_id, presence: true
  property :user_id, presence: true
  property :policy_id, presence: true
  property :invoice_id, presence: true
  property :department_id, presence: true
  property :cost_center_id, presence: true
  property :billing_location_id, presence: true
  property :shipping_location_id, presence: true
  property :vendor_id, presence: true
  property :narration
  property :tds_rate_id, presence: true

  property :current_user, virtual: true
  property :status_id, default: CreditNoteStatus.id_for(:draft)

  collection :items, populator: :items! do
    # property :credit_note_item_type_id, presence: true
    property :item_id, presence: true
    property :invoice_item_id, presence: true
    property :category_id, presence: true
    property :comment, presence: true
    property :hsn_sac, presence: true
    property :original_quantity, presence: true
    property :quantity, presence: true
    property :original_rate, presence: true
    property :rate, presence: true
    property :original_taxable_amount, populate_if_empty: Amount do
      property :id
      property :value, presence: true
      property :currency_id, presence: true
    end
    property :taxable_amount, populate_if_empty: Amount do
      property :id
      property :value, presence: true
      property :currency_id, presence: true
    end

    property :original_tax_rate_id, presence: true
    property :tax_rate_id, presence: true
  end

  validate :company_entities # Checks for departments
  # validate :related_entities # Checks for associated agreements, users provided inside pocs

  # validate :company_specific_entities

  def company_entities
    params = {filter_role_id: [UserRole.id_for(:credit_note_initiator)], current_app: :vp}
    errors.add(:policy_id, "Invalid Policy") unless ::Policy::VendorPayments::Index.(current_user, params).policies.find_by(id: policy_id).present?
  end

  private

  # def amount!(fragment:, **)
  #
  # end

  def items!(collection:, fragment:, index:, options:, **)
    item = items.find {|item| item.id.to_s == fragment["id"].to_s}


    # if fragment["_destroy"]
    #   items.delete(item)
    #   return skip!
    # end


    item ? items.insert(index, item.model) : items.insert(index, CreditNoteItem.new)
  end
end