FactoryBot.define do
  factory :purchase_request do
    status_id { 1 }
    title { "MyText" }
    location_id { 1 }
    department_id { 1 }
    policy_id { 1 }
    controlling_level_id { 1 }
    user { nil }
    company { nil }
  end
end
