# == Schema Information
#
# Table name: rate_contracts
#
#  id                      :bigint           not null, primary key
#  name                    :string(255)
#  vendor_id               :integer
#  renewable               :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  item_id                 :integer
#  creator_id              :integer
#  renewal_alert_number    :integer
#  renewal_alert_period_id :integer
#  note                    :string(255)
#  company_id              :integer
#  rate_contract_number    :string(255)
#

FactoryBot.define do
  factory :rate_contract do
    name { "MyString" }
    vendor_id { 1 }
    renewal_alert { "MyString" }
    renewable { false }
  end
end
