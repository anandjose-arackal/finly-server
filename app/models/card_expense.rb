class CardExpense < ActiveRecord::Base
  belongs_to :card_transaction
  belongs_to :expense
end
