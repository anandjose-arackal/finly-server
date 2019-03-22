# == Schema Information
#
# Table name: artifacts
#
#  id                      :bigint(8)        not null, primary key
#  resource_id             :integer
#  resource_type           :string(255)
#  attachment_file_name    :string(255)
#  attachment_file_size    :integer
#  attachment_content_type :string(255)
#  attachment_updated_at   :datetime
#  description             :text(65535)
#  company_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  creator_id              :integer
#

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
