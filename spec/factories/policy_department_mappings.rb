# == Schema Information
#
# Table name: policy_department_mappings
#
#  id            :integer          not null, primary key
#  policy_id     :integer          not null
#  department_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  enabled       :boolean
#

FactoryBot.define do
  factory :policy_department_mapping do
    policy_id { 1 }
    department_id { 1 }
    enabled { false }
  end
end
