# == Schema Information
#
# Table name: money_request_items
#
#  id               :integer          not null, primary key
#  money_request_id :integer          not null
#  category_id      :integer          not null
#  amount_id        :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class MoneyRequestItem < ActiveRecord::Base
  belongs_to :category
  belongs_to :amount
  belongs_to :money_request

  scope :with_amount, -> { joins :amount }
  scope :with_category, ->(category_id){ where category_id: category_id }

  accepts_nested_attributes_for :amount

end
