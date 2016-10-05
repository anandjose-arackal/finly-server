# == Schema Information
#
# Table name: card_transaction_restrictions
#
#  id                     :integer          not null, primary key
#  count                  :integer
#  card_id                :integer
#  period_id              :integer
#  product_combination_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class CardTransactionRestriction < ActiveRecord::Base
  belongs_to :card
  belongs_to :product_combination
end
