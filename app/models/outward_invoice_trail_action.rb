# == Schema Information
#
# Table name: outward_invoice_trail_actions
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class OutwardInvoiceTrailAction < ApplicationRecord
  include Seedable

  def self.values
    [
        :credit_virtual_account,
        :credit_customer_account,
        :credit_outside,
        :credit_advance,
        :credit_credit_note,
        :debit_customer_account,
        :debit_outside
    ]
  end
end
