# == Schema Information
#
# Table name: user_device_types
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :user_device_type do
    name { "MyString" }
  end
end
