class CardUpdateRequest < ActiveRecord::Base
  belongs_to :card
  belongs_to :card_program
end
