# == Schema Information
#
# Table name: payment_agreement_types
#
#  id         :bigint           not null, primary key
#  name       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

FactoryBot.define do
  factory :payment_agreement_type do
    name { 1 }
  end
end
