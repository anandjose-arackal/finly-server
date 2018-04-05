# == Schema Information
#
# Table name: invoice_transaction_mappings
#
#  id                :integer          not null, primary key
#  invoice_id        :integer
#  va_transaction_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class InvoiceTransactionMapping < ActiveRecord::Base

  belongs_to :invoice, class_name: "OutwardInvoice"
  belongs_to :va_transaction, class_name: "VirtualAccountTransaction"
end
