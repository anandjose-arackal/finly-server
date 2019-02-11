# == Schema Information
#
# Table name: card_balance_histories
#
#  id         :integer          not null, primary key
#  card_id    :integer
#  amount_id  :integer
#  timestamp  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CardBalanceHistory < ApplicationRecord
  belongs_to :card, optional: true
  belongs_to :amount, optional: true

  validates :card_id, presence: true
  validates :amount_id, presence: true


  accepts_nested_attributes_for :amount
end
