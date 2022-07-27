class Masters::CreditNoteItemTypes::Lookup < Lookup::API

  resolver 'credit_note_item_types.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name
end
