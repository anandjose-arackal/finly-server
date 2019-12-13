class Docs::P2P::CreditNotes::Contracts::Update < Reform::Form

  property :id
  property :policy_id, presence: true
  property :narration
  property :credit_note_date

  collection :items, populator: :items! do
    property :credit_note_item_type_id, presence: true
    property :comment
    property :quantity, presence: true
    property :rate, presence: true
    property :taxable_amount, populate_if_empty: Amount do
      property :id
      property :value, presence: true
      property :currency_id, presence: true
    end
    property :tax_rate_id, presence: true
  end

  validate :company_entities # Checks for departments
  # validate :related_entities # Checks for associated agreements, users provided inside pocs
  validate :validate_customer_params

  # validate :company_specific_entities

  private

  def items!(collection:, fragment:, index:, options:, **)
    item = items.find {|item| item.id.to_s == fragment["id"].to_s}

    if fragment["_destroy"]
      items.delete(item)
      return skip!
    end

    item ? items.insert(index, item.model) : items.insert(index, CreditNoteItem.new)
  end
end