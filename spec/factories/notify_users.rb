# == Schema Information
#
# Table name: notify_users
#
#  id            :bigint           not null, primary key
#  user_id       :integer
#  company_id    :integer
#  document_id   :integer
#  document_type :string(255)
#  enabled       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#

FactoryBot.define do
  factory :notify_user do
    user_id { 1 }
    company_id { 1 }
    document_id { 1 }
    document_type { "MyString" }
    enabled { false }
  end
end
