# == Schema Information
#
# Table name: payment_purposes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaymentPurpose < ApplicationRecord
  include Seedable

  def self.values
    [
        :atm_withdrawal,
        :card_transaction,
        :advance_outside_finly,
        :reimbursement_outside_finly,
        :advance,
        :medical_benefit,
        :meal_benefit,
        :reimbursement,
        :payroll,
        :vendor_payment,
        :corporate_balance_load,
        :balance_clearance_outside_finly,
        :balance_clearance,
        :corporate_balance_refund,
        :personal_expense,
        :card_auto_reload,
        :fees,
        :reissue_transfer,
        :cash_advance,
        :balance_clearance_against_cash_on_hand,
        :settlement_against_cash_on_hand,
        :advance_against_report_unapproval,
        :cash_on_hand_reversal,
        :virtual_account_credit,
        :payment_link_credit,
        :invoice_credit,
        :cash_on_hand_return,
        :payment_receivable,
        :invoice,
        :virtual_bank_account,
        :finly_money_reload,
        :corporate_account_reload,
        :blocked_for_conflict_resolution,
        :unblocked_after_conflict_resolution,
        :failed_transaction_reversal,
        :opening_balance_load,
        :collect_funds_withdrawal,
        :settlement_against_advance,
        :advance_against_purchase_order
    ]
  end
end