# == Schema Information
#
# Table name: policy_location_department_mappings
#
#  id            :bigint(8)        not null, primary key
#  location_id   :integer
#  department_id :integer
#  policy_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :policy_location_department_mapping do
    location_id { 1 }
    department_id { 1 }
    policy_id { 1 }
  end
end
