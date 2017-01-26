# == Schema Information
#
# Table name: payment_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#




class PaymentType < ActiveRecord::Base
  has_many :payments

  TYPES = {advance: 1, debt_clearance: 2, reimbursement: 3, settlement: 4,
           credit_from_virtual_account_to_wallet: 5,
           credit_from_virtual_account_to_card: 6,
           credit_from_wallet_to_wallet: 7,
           credit_from_wallet_to_card: 8,
           debit_from_wallet_to_wallet: 9,
           debit_from_wallet_to_virtual_account: 10,
           atm_withdrawal: 11,
           debit_from_card_to_virtual_account: 12,
           debit_from_card_to_wallet: 13,
           debit_from_card_to_card: 14,
           credit_from_card_to_card: 15,
           credit_from_card_to_wallet: 16}

  def self.id_for(key)
    TYPES[key]
  end

  def self.name_for(id)
    TYPES.key(id).to_s.humanize rescue nil
  end

end
