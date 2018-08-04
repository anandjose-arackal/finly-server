# == Schema Information
#
# Table name: user_pocket_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserPocketType < ActiveRecord::Base

  include Seedable

  def self.values
    %w(bank_transfer card_transfer cash atm_withdrawals credit_card)
  end
end
