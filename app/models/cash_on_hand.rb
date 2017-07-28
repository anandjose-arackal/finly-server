# == Schema Information
#
# Table name: cash_on_hands
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  balance_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CashOnHand < ActiveRecord::Base
  belongs_to :user

  has_many :payments, as: :initiating_account
  has_many :payments, as: :receiving_account
end
