FactoryBot.define do
  factory :quotation do
    vendor_name { "MyString" }
    vendor_location { "MyString" }
    estimated_delivery_time { "MyString" }
    total_amount { "MyString" }
    advance_amount { "MyString" }
    credit_period { "MyString" }
    note { "MyText" }
    selected { false }
  end
end
