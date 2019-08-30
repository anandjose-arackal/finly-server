FactoryBot.define do
  factory :security_deposit do
    vendor_id { 1 }
    vendor_location_id { 1 }
    cost_center_id { 1 }
    department_id { 1 }
    location_id { 1 }
    note { "MyText" }
    description { "MyText" }
    payable_amount_id { 1 }
    original_amount_id { 1 }
  end
end
