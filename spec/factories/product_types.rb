# == Schema Information
#
# Table name: product_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :product_type do
    name { "MyString" }
  end
end
