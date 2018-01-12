# == Schema Information
#
# Table name: outward_invoices
#
#  id                 :integer          not null, primary key
#  customer_id        :integer
#  invoice_date       :date
#  invoice_due_date   :date
#  amount_id          :integer
#  discount           :decimal(10, 5)
#  tax                :decimal(10, 5)
#  discount_amount_id :integer
#  tax_amount_id      :integer
#  original_amount_id :integer
#  paid_amount_id     :integer
#  advance            :decimal(10, 5)
#  freight_amount_id  :integer
#  tds_amount_id      :integer
#  category_id        :integer
#  balance_due_id     :integer
#  roundoff_amount    :decimal(10, 5)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class OutwardInvoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
