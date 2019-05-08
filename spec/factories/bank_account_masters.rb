# == Schema Information
#
# Table name: bank_account_masters
#
#  id             :bigint(8)        not null, primary key
#  account_number :string(255)
#  ifsc           :string(255)
#  account_name   :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryBot.define do
  factory :bank_account_master do
    
  end
end
