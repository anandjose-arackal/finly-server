FactoryBot.define do
  factory :gst do
    gstin { "MyString" }
    verified { false }
    api_response { "" }
    gst_location_id { 1 }
  end
end
