# == Schema Information
#
# Table name: document_message_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :document_message_type do
    name { "MyString" }
  end
end
