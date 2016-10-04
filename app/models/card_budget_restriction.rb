class CardBudgetRestriction < ActiveRecord::Base
  belongs_to :card
  belongs_to :product_combination
end
