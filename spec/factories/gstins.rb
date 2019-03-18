FactoryBot.define do
  factory :gstin do
    gstin { "MyString" }
    legal_name_of_business { "MyString" }
    state { "MyString" }
    date_of_registration { "2019-03-18" }
    constitution_of_business { "MyString" }
    taxpayer_type { "MyString" }
    status { "MyString" }
    api_response { "MyText" }
    api_provider { "MyString" }
  end
end
