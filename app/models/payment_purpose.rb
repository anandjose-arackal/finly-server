# == Schema Information
#
# Table name: payment_purposes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentPurpose < ActiveRecord::Base
  include Seedable

  def self.values
    [:atm_withdrawal, :card_transaction, :fund_transfer_outside_finly, :reimbursement_outside_finly, :fund_transfer, :reimbursement, :vendor_payment]
  end

end
