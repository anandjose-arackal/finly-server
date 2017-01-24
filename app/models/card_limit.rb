class CardLimit < ActiveRecord::Base
  belongs_to :dummy_restriction

  belongs_to :amount
  belongs_to :period
end
