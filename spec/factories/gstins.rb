# == Schema Information
#
# Table name: gstins
#
#  id                       :bigint(8)        not null, primary key
#  gstin                    :string(255)
#  legal_name_of_business   :string(255)
#  state                    :string(255)
#  date_of_registration     :date
#  constitution_of_business :string(255)
#  taxpayer_type            :string(255)
#  status                   :string(255)
#  api_response             :text(65535)
#  api_provider             :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  address                  :text(65535)
#

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
