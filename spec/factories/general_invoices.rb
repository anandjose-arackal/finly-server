FactoryBot.define do
  factory :general_invoice do
    vendor_id { 1 }
    department_id { 1 }
    location_id { 1 }
    cost_center_id { 1 }
    payment_term_id { 1 }
    auto_pay { false }
    note { "MyText" }
    billing_type_id { 1 }
  end
end
