class Masters::AdjustableCreditNotes::Lookup < Lookup::API

  resolver 'adjustable_credit_notes.default'
  search_key :credit_note_id_or_credit_note_number_cont

  attribute :id, visible: false
  attribute :credit_note_id
  attribute :name, value: "{{record.sequence_id}}"
  attribute :credit_note_number
  attribute :cn_net_adjustable_amount, value: "{{record.cn_net_adjustable_amount}}"
    
end