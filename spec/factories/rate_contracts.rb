FactoryBot.define do
  factory :rate_contract do
    name { "MyString" }
    vendor_id { 1 }
    renewal_alert { "MyString" }
    renewable { false }
  end
end
