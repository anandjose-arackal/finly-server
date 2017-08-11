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
    [:atm_withdrawal, :card_transaction, :advance_outside_finly, :reimbursement_outside_finly, :advance, :medical_benefit, :meal_benefit, :reimbursement, :payroll, :vendor_payment, :corporate_balance_load, :balance_clearance_outside_finly, :balance_clearance, :corporate_balance_refund]
  end

end
