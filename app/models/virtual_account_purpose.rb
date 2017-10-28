# == Schema Information
#
# Table name: virtual_account_purposes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class VirtualAccountPurpose < ActiveRecord::Base
  include Seedable

  # cash_on_hand_reversal - when employees return their cash advance through a bank transfer
  # payment_receivable - when the account is used for a single incoming payment
  # invoice - when the account is used for paying an invoice
  # virtual_bank_account - just plain vanilla bank account
  # corporate balance reload - when a company wants to reload their yes bank account

  def self.values
    [:cash_on_hand_return, :payment_receivable, :invoice, :virtual_bank_account, :corporate_account_reload]
  end

end
