FactoryBot.define do
  factory :attachment do
    resource_id { "" }
    resource_type { "" }
    attachment_file_name { "MyString" }
    attachment_file_size { "" }
    attachment_content_type { "" }
    attachment_updated_at { "" }
    company_id { "" }
    creator_id { 1 }
  end
end
