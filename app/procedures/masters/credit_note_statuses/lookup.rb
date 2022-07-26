class Masters::CreditNoteStatuses::Lookup < Lookup::API

  resolver 'credit_note_statuses.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name
end
