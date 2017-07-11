class CardAssignRequest < ActiveRecord::Base
  belongs_to :card
  belongs_to :card_program
end
