# == Schema Information
#
# Table name: payment_agreement_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#

FactoryBot.define do
  factory :payment_agreement_status do
    name { "MyString" }
  end
end
