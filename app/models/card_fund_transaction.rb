class CardFundTransaction < ActiveRecord::Base
  belongs_to :requesting_user
  belongs_to :for_user
end
