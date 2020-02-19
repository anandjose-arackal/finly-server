# == Schema Information
#
# Table name: billing_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid       :string(36)
#  deleted_at :datetime
#

FactoryBot.define do
  factory :billing_type do
    name { "" }
    company_id { 1 }
  end
end
