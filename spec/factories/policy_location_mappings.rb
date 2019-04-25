# == Schema Information
#
# Table name: policy_location_mappings
#
#  id          :bigint(8)        not null, primary key
#  policy_id   :integer
#  location_id :integer
#  enabled     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :policy_location_mapping do
    policy_id { 1 }
    location_id { 1 }
    enabled { false }
  end
end
