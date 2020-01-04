# == Schema Information
#
# Table name: collect_transaction_purposes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CollectTransactionPurpose < ApplicationRecord
  include Seedable

  def self.values
    [:cash_on_hand_return, :payment_receivable, :invoice, :virtual_bank_account]
  end
end
