FactoryBot.define do
  factory :artifact do
    resource_id { 1 }
    resource_type { "MyString" }
    attachment_file_name { "MyString" }
    attachment_file_size { 1 }
    attachment_content_type { "MyString" }
    attachment_updated_at { "2019-02-12 14:42:42" }
    description { "MyText" }
    company_id { 1 }
  end
end
