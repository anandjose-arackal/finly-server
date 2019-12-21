# == Schema Information
#
# Table name: policy_department_mappings
#
#  id            :bigint           not null, primary key
#  policy_id     :integer
#  department_id :integer
#  enabled       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :policy_department_mapping do
    policy_id { 1 }
    department_id { 1 }
    enabled { false }
  end
end
