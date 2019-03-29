FactoryBot.define do
  factory :policy_location_mapping do
    policy_id { 1 }
    location_id { 1 }
    enabled { false }
  end
end
