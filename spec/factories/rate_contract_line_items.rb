FactoryBot.define do
  factory :rate_contract_line_item do
    location_id { 1 }
    item_id { 1 }
    start_date { "2019-02-08 04:29:55" }
    end_date { "2019-02-08 04:29:55" }
    amount { "9.99" }
    rate_contract_id { 1 }
  end
end
