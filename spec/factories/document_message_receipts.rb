# == Schema Information
#
# Table name: document_message_receipts
#
#  id                        :bigint           not null, primary key
#  user_id                   :integer          not null
#  receiptable_document_id   :integer          not null
#  receiptable_document_type :string(255)      not null
#  document_message_id       :integer          not null
#  browser_push_sent_at      :datetime
#  app_push_sent_at          :datetime
#  email_sent_at             :datetime
#  read_at                   :datetime
#  trashed_at                :datetime
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryBot.define do
  factory :document_message_receipt do
    user_id { 1 }
    document_id { 1 }
    document_type { "MyString" }
    last_read_at { "2019-03-15 14:04:34" }
  end
end
