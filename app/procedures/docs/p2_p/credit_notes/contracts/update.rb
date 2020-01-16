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

  validate :items_validation

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

  def items_validation
    items.each_with_index do |item, index|
      case item.credit_note_item_type_id
      when CreditNoteItemType.id_for(:qty_change)
        validate_qty_change(item, index)
      when CreditNoteItemType.id_for(:price_drop)
        validate_price_drop(item, index)
      when CreditNoteItemType.id_for(:gst_change)
        validate_gst_change(item, index)
      end
    end
    true
  end

  def validate_qty_change(item, index)
    errors.add(:base, "CN Quantity cannot be greater than Invoice Quantity for Item ##{index + 1}") if item.quantity.to_f > item.model.original_quantity.to_f
    errors.add(:base, "Only Quantity can be changed for Item ##{index + 1}") if (item.rate.to_f != item.model.original_rate.to_f || item.tax_rate_id != item.model.original_tax_rate_id)
  end

  def validate_price_drop(item, index)
    errors.add(:base, "CN Rate / Price cannot be greater than Invoice Rate / Price for Item ##{index + 1}") if item.rate.to_f > item.model.original_rate.to_f
    errors.add(:base, "Only Rate / Price can be changed for Item # #{index + 1}") if (item.quantity.to_f != item.model.original_quantity.to_f || item.tax_rate_id != item.model.original_tax_rate_id)
  end

  def validate_gst_change(item, index)
    errors.add(:base, "CN GST Tax Rate cannot be greater than Invoice Tax Rate for Item ##{index + 1}") if TaxRate.find_by(id: item.tax_rate_id).rate.to_f > item.model.original_tax_rate.rate.to_f
    errors.add(:base, "Only GST Tax Rate can be changed for Item # #{index + 1}") if (item.quantity.to_f != item.model.original_quantity.to_f || item.rate.to_f != item.model.original_rate.to_f)
  end
end