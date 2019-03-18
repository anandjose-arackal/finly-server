FactoryBot.define do
  factory :gstin_location do
    vendor_id { 1 }
    gstin { nil }
    gstin { "MyString" }
    location_id { 1 }
    state { nil }
    poc_name { "MyString" }
    poc_mobile_number { "MyString" }
    poc_email { "MyString" }
    poc_fax { "MyString" }
    poc_designation { "MyString" }
  end
end
