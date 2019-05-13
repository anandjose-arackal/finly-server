# == Schema Information
#
# Table name: document_messages
#
#  id                        :bigint           not null, primary key
#  order                     :integer
#  user_id                   :integer
#  type_id                   :integer
#  body                      :text(65535)
#  attachment_file_name      :string(255)
#  attachment_content_type   :string(255)
#  attachment_file_size      :bigint
#  attachment_updated_at     :datetime
#  deleted_at                :datetime
#  trashed_at                :datetime
#  messageable_document_id   :integer          not null
#  messageable_document_type :string(255)      not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryBot.define do
  factory :document_message do
    user { nil }
    type_id { 1 }
    body { "MyText" }
    deleted_at { "2019-03-15 14:04:02" }
    chatable_document_id { 1 }
    chatable_document_type { "MyString" }
  end
end
