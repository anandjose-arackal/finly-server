FactoryBot.define do
  factory :policy_department_mapping do
    policy_id { 1 }
    department_id { 1 }
    enabled { false }
  end
end
