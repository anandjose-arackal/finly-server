# == Schema Information
#
# Table name: card_limits
#
#  id                   :integer          not null, primary key
#  dummy_restriction_id :integer
#  amount_id            :integer
#  transaction_limit    :integer
#  period_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  amount               :decimal(10, )
#

class CardLimit < ActiveRecord::Base
  belongs_to :dummy_restriction

  belongs_to :amount
  belongs_to :period
end
