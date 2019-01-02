# require './company'
FactoryBot.define do
  sequence :policy_name do |n|
    "Policy - #{n}"
  end

  factory :policy do
    name { generate(:policy_name) }
    company
    default { false }
  end
end

