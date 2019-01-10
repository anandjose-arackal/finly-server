# require './company'
FactoryBot.define do
  sequence :level_number do |n|
    n
  end

  factory :reviewal_level do
    policy_id {nil}
    associated_entity_type {'ReportProvider'}
    level_number {generate(:level_number)}
  end

  factory :level_reviewer_mappings
end