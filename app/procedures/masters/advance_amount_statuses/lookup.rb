class Masters::AdvanceAmountStatuses::Lookup < Lookup::API

    resolver 'advance_amount_statuses.default'
    search_key :name_cont
  
    attribute :id, visible: false
    attribute :name
end