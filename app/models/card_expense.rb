class CardExpense < ActiveRecord::Base
  belongs_to :transaction
  belongs_to :expense
end
