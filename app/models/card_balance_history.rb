class CardBalanceHistory < ActiveRecord::Base
  belongs_to :card
  belongs_to :amount

  accepts_nested_attributes_for :amount
end
