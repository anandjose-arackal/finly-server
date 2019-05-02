# == Schema Information
#
# Table name: attachments
#
#  id                :bigint(8)        not null, primary key
#  resource_id       :integer
#  resource_type     :string(255)
#  file_file_name    :string(255)
#  file_file_size    :decimal(64, 12)
#  file_content_type :string(255)
#  file_updated_at   :datetime
#  company_id        :integer
#  creator_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  description       :text(65535)
#

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
