# == Schema Information
#
# Table name: purchase_request_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :purchase_request_status do
    name { "MyString" }
  end
end
