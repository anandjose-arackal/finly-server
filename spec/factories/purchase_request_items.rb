FactoryBot.define do
  factory :purchase_request_item do
    purchase_request { nil }
    vendor_id { 1 }
    location_id { 1 }
    comment { "MyText" }
    quantity { 1 }
    unit_amount_id { 1 }
    estimated_amount_id { 1 }
  end
end
