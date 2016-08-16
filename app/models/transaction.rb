class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :card

  has_one :card_expense
end
