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
           card_transfer_initiating_credit: 5, card_transfer_initiating_debit: 6,
           card_transfer_receiving_credit: 7, card_transfer_receiving_debit: 8,
           card_credit: 9, card_debit: 10}

  def self.id_for(key)
    TYPES[key]
  end

end
