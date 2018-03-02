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

require 'test_helper'

class InvoiceTransactionMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
