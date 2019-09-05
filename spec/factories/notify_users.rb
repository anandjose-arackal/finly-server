FactoryBot.define do
  factory :notify_user do
    user_id { 1 }
    company_id { 1 }
    document_id { 1 }
    document_type { "MyString" }
    enabled { false }
  end
end
