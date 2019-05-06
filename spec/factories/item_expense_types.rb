# == Schema Information
#
# Table name: item_expense_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :item_expense_type do
    id { 1 }
    name { "MyString" }
  end
end
